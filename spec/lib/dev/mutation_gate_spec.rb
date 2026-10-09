require "json"
require "open3"
require "tmpdir"
require_relative "../../../lib/dev/mutation_gate"

RSpec.describe MutationGate do
  def git(root, *args)
    _out, err, status = Open3.capture3("git", *args, chdir: root)
    raise("git #{args.join(" ")} failed: #{err}") unless status.success?
  end

  def write(root, path, content = "# #{path}\n")
    full = File.join(root, path)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, content)
  end

  def with_repo(base_files: ["README.md"])
    Dir.mktmpdir do |root|
      git(root, "init", "-q", "-b", "main")
      git(root, "config", "user.email", "spec@example.com")
      git(root, "config", "user.name", "Spec")
      git(root, "config", "commit.gpgsign", "false")
      base_files.each { |path| write(root, path) }
      git(root, "add", "-A")
      git(root, "commit", "-q", "-m", "base")
      git(root, "switch", "-q", "-c", "feature")
      yield(root)
    end
  end

  def commit_all(root, message = "change")
    git(root, "add", "-A")
    git(root, "commit", "-q", "-m", message)
  end

  def merge_base(root)
    out, _status = Open3.capture2("git", "merge-base", "main", "HEAD",
      chdir: root)
    out.strip
  end

  def plan(root, **options)
    MutationGate.plan(root:, base: "main", report: "tmp/report.json",
      **options)
  end

  def tests_of(run)
    run.argv.each_cons(2).filter_map { |flag, path| path if flag == "--test" }
  end

  describe ".plan" do
    it "builds a mutineer command scoped to the merge-base" do
      with_repo do |root|
        write(root, "app/models/user.rb")
        write(root, "spec/models/user_spec.rb")
        commit_all(root)
        sha = merge_base(root)

        run = plan(root)

        expect(run).to be_a(MutationGate::Run)
        expect(run.argv).to eq([
          "bundle", "exec", "mutineer", "run", "app",
          "--since", sha,
          "--test", "spec/models/user_spec.rb",
          "--format", "json", "--output", "tmp/report.json"
        ])
        expect(run.report).to eq("tmp/report.json")
      end
    end

    it "diffs against the merge-base, not the tip of main" do
      with_repo do |root|
        write(root, "app/models/user.rb")
        write(root, "spec/models/user_spec.rb")
        commit_all(root)
        sha = merge_base(root)
        git(root, "switch", "-q", "main")
        write(root, "app/models/post.rb")
        write(root, "spec/models/post_spec.rb")
        commit_all(root, "advance main")
        git(root, "switch", "-q", "feature")

        run = plan(root)

        expect(run.argv.each_cons(2).to_a).to include(["--since", sha])
        expect(tests_of(run)).to eq(["spec/models/user_spec.rb"])
      end
    end

    it "includes committed, staged, unstaged, and untracked specs" do
      with_repo(base_files: ["spec/models/staged_spec.rb",
        "spec/models/unstaged_spec.rb"]) do |root|
        write(root, "app/models/user.rb")
        write(root, "spec/models/committed_spec.rb")
        commit_all(root)
        write(root, "spec/models/staged_spec.rb", "# staged\n")
        git(root, "add", "spec/models/staged_spec.rb")
        write(root, "spec/models/unstaged_spec.rb", "# unstaged\n")
        write(root, "spec/models/untracked_spec.rb")

        run = plan(root)

        expect(tests_of(run)).to contain_exactly(
          "spec/models/committed_spec.rb",
          "spec/models/staged_spec.rb",
          "spec/models/unstaged_spec.rb",
          "spec/models/untracked_spec.rb"
        )
      end
    end

    it "excludes deleted specs and deleted app files" do
      with_repo(base_files: ["app/models/gone.rb",
        "spec/models/gone_spec.rb", "spec/models/old_spec.rb"]) do |root|
        write(root, "app/models/user.rb")
        write(root, "spec/models/user_spec.rb")
        git(root, "rm", "-q", "app/models/gone.rb", "spec/models/old_spec.rb")
        commit_all(root)

        run = plan(root)

        expect(tests_of(run)).to eq(["spec/models/user_spec.rb"])
      end
    end

    it "pairs a changed app file with its mirrored spec" do
      with_repo(base_files: ["spec/models/user_spec.rb"]) do |root|
        write(root, "app/models/user.rb")
        write(root, "app/models/post.rb")
        commit_all(root)

        run = plan(root)

        expect(tests_of(run)).to eq(["spec/models/user_spec.rb"])
      end
    end

    it "pairs an untracked app file with its mirrored spec" do
      with_repo(base_files: ["spec/models/user_spec.rb"]) do |root|
        write(root, "app/models/user.rb")

        run = plan(root)

        expect(tests_of(run)).to eq(["spec/models/user_spec.rb"])
      end
    end

    it "pairs a changed controller with its request specs" do
      with_repo(base_files: ["spec/requests/galleries_spec.rb",
        "spec/requests/homes_controller_spec.rb"]) do |root|
        write(root, "app/controllers/galleries_controller.rb")
        write(root, "app/controllers/homes_controller.rb")
        write(root, "app/controllers/posts_controller.rb")
        commit_all(root)

        run = plan(root)

        expect(tests_of(run)).to contain_exactly(
          "spec/requests/galleries_spec.rb",
          "spec/requests/homes_controller_spec.rb"
        )
      end
    end

    it "leaves system specs out of the default selection" do
      with_repo do |root|
        write(root, "app/models/user.rb")
        write(root, "spec/models/user_spec.rb")
        write(root, "spec/system/users_spec.rb")
        commit_all(root)

        run = plan(root)

        expect(tests_of(run)).to eq(["spec/models/user_spec.rb"])
      end
    end

    it "replaces the default selection with named specs" do
      with_repo do |root|
        write(root, "app/models/user.rb")
        write(root, "spec/models/user_spec.rb")
        commit_all(root)

        run = plan(root, specs: ["spec/system/users_spec.rb"])

        expect(tests_of(run)).to eq(["spec/system/users_spec.rb"])
      end
    end

    it "appends passthrough arguments after its own" do
      with_repo do |root|
        write(root, "app/models/user.rb")
        write(root, "spec/models/user_spec.rb")
        commit_all(root)

        run = plan(root, passthrough: ["--only", "User#name"])

        expect(run.argv.last(2)).to eq(["--only", "User#name"])
      end
    end

    it "skips successfully when nothing changed under app" do
      with_repo do |root|
        write(root, "spec/models/user_spec.rb")
        write(root, "README.md", "# changed\n")
        commit_all(root)

        skip = plan(root)

        expect(skip).to be_a(MutationGate::Skip)
        expect(skip.success).to be(true)
        expect(skip.message).to match(/nothing to mutate/i)
      end
    end

    it "stops when it finds no specs to run" do
      with_repo do |root|
        write(root, "app/models/user.rb")
        commit_all(root)

        skip = plan(root)

        expect(skip).to be_a(MutationGate::Skip)
        expect(skip.success).to be(false)
        expect(skip.message).to match(/no specs/i)
      end
    end
  end

  describe ".verdict" do
    def report(survivors: [], no_coverage: [])
      JSON.generate({
        schema_version: "1.7",
        summary: {total: 3, killed: 3 - survivors.size,
                  survived: survivors.size, no_coverage: no_coverage.size},
        survivors:,
        no_coverage:
      })
    end

    def mutant(line:, operator:)
      {subject: "User#name", file: "app/models/user.rb", line:, operator:,
       id: "abc123def456", token: "x"}
    end

    it "passes when every mutation was killed" do
      verdict = MutationGate.verdict(report)

      expect(verdict).to be_passed
      expect(verdict.survivors).to be_empty
      expect(verdict.uncovered).to be_empty
      expect(verdict.to_s).to eq("No surviving or uncovered mutations.\n")
    end

    it "fails and lists a survivor" do
      json = report(survivors: [mutant(line: 4, operator: "comparison")])

      verdict = MutationGate.verdict(json)

      expect(verdict).not_to be_passed
      expect(verdict.survivors.map(&:to_s)).to eq([
        "app/models/user.rb:4 comparison User#name (abc123def456)"
      ])
    end

    it "fails and lists an uncovered mutation" do
      json = report(no_coverage: [mutant(line: 7, operator: "return_nil")])

      verdict = MutationGate.verdict(json)

      expect(verdict).not_to be_passed
      expect(verdict.uncovered.map(&:to_s)).to eq([
        "app/models/user.rb:7 return_nil User#name (abc123def456)"
      ])
    end

    it "lists survivors and uncovered mutations together" do
      json = report(
        survivors: [mutant(line: 4, operator: "comparison")],
        no_coverage: [mutant(line: 7, operator: "return_nil")]
      )

      verdict = MutationGate.verdict(json)

      expect(verdict).not_to be_passed
      expect(verdict.to_s).to eq(<<~TEXT)
        Survived (1):
          app/models/user.rb:4 comparison User#name (abc123def456)
        No coverage (1):
          app/models/user.rb:7 return_nil User#name (abc123def456)
      TEXT
    end
  end
end
