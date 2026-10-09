# typed: strict

require "json"
require "open3"
require "sorbet-runtime"

class MutationGate
  extend T::Sig

  SOURCE = "app"

  class Run < T::Struct
    const :argv, T::Array[String]
    const :report, String
  end

  class Skip < T::Struct
    const :message, String
    const :success, T::Boolean
  end

  class Mutant < T::Struct
    extend T::Sig

    const :file, String
    const :line, Integer
    const :operator, String
    const :subject, String
    const :id, String

    sig { params(entry: T::Hash[String, T.untyped]).returns(Mutant) }
    def self.from_report(entry)
      new(
        file: entry.fetch("file"),
        line: entry.fetch("line"),
        operator: entry.fetch("operator"),
        subject: entry.fetch("subject"),
        id: entry.fetch("id")
      )
    end

    sig { returns(String) }
    def to_s
      "#{file}:#{line} #{operator} #{subject} (#{id})"
    end
  end

  class Verdict < T::Struct
    extend T::Sig

    const :survivors, T::Array[Mutant]
    const :uncovered, T::Array[Mutant]

    sig { returns(T::Boolean) }
    def passed?
      survivors.empty? && uncovered.empty?
    end

    sig { returns(String) }
    def to_s
      return "No surviving or uncovered mutations.\n" if passed?

      [
        listing("Survived", survivors),
        listing("No coverage", uncovered)
      ].join
    end

    private

    sig { params(title: String, mutants: T::Array[Mutant]).returns(String) }
    def listing(title, mutants)
      return "" if mutants.empty?

      lines = mutants.map { |mutant| "  #{mutant}\n" }
      "#{title} (#{mutants.size}):\n#{lines.join}"
    end
  end

  sig do
    params(
      root: String,
      base: String,
      report: String,
      specs: T::Array[String],
      passthrough: T::Array[String]
    ).returns(T.any(Run, Skip))
  end
  def self.plan(root:, base:, report:, specs: [], passthrough: [])
    new(root:, base:).plan(report:, specs:, passthrough:)
  end

  sig { params(json: String).returns(Verdict) }
  def self.verdict(json)
    data = JSON.parse(json)
    Verdict.new(
      survivors: data.fetch("survivors").map { Mutant.from_report(it) },
      uncovered: data.fetch("no_coverage").map { Mutant.from_report(it) }
    )
  end

  sig { params(root: String, base: String).void }
  def initialize(root:, base:)
    @root = root
    @base = base
  end

  sig do
    params(
      report: String,
      specs: T::Array[String],
      passthrough: T::Array[String]
    ).returns(T.any(Run, Skip))
  end
  def plan(report:, specs:, passthrough:)
    if changed_sources.empty?
      return Skip.new(message: "Nothing to mutate: no Ruby changed under " \
        "#{SOURCE}/ since #{@base}.", success: true)
    end

    tests = specs.empty? ? default_specs : specs
    if tests.empty?
      return Skip.new(message: "No specs to run. Name spec files: " \
        "bin/mutate spec/path/to_spec.rb", success: false)
    end

    argv = ["bundle", "exec", "mutineer", "run", SOURCE, "--since", merge_base]
    tests.each { argv.push("--test", it) }
    argv.push("--format", "json", "--output", report)
    argv.concat(passthrough)
    Run.new(argv:, report:)
  end

  private

  sig { returns(T::Array[String]) }
  def default_specs
    candidates = changed_specs + changed_sources.flat_map { paired_specs(it) }
    candidates.uniq.select { File.file?(File.join(@root, it)) }.sort
  end

  sig { returns(T::Array[String]) }
  def changed_specs
    changed_files.select do |path|
      path.start_with?("spec/") && path.end_with?("_spec.rb") &&
        !path.start_with?("spec/system/")
    end
  end

  sig { returns(T::Array[String]) }
  def changed_sources
    @changed_sources ||= T.let(
      changed_files.select do |path|
        path.start_with?("#{SOURCE}/") && path.end_with?(".rb")
      end,
      T.nilable(T::Array[String])
    )
  end

  sig { params(source: String).returns(T::Array[String]) }
  def paired_specs(source)
    relative = source.delete_prefix("#{SOURCE}/").delete_suffix(".rb")
    pairs = ["spec/#{relative}_spec.rb"]
    controller = relative.delete_prefix("controllers/")
    if controller != relative && controller.end_with?("_controller")
      name = controller.delete_suffix("_controller")
      pairs.push("spec/requests/#{name}_spec.rb",
        "spec/requests/#{controller}_spec.rb")
    end
    pairs
  end

  sig { returns(T::Array[String]) }
  def changed_files
    @changed_files ||= T.let(
      (
        git("diff", "--name-only", "--diff-filter=d", merge_base) +
        git("ls-files", "--others", "--exclude-standard")
      ).uniq,
      T.nilable(T::Array[String])
    )
  end

  sig { returns(String) }
  def merge_base
    @merge_base ||= T.let(
      T.must(git("merge-base", @base, "HEAD").first),
      T.nilable(String)
    )
  end

  sig { params(args: String).returns(T::Array[String]) }
  def git(*args)
    out, err, status = T.unsafe(Open3).capture3("git", *args, chdir: @root)
    raise("git #{args.join(" ")} failed: #{err}") unless status.success?

    out.lines(chomp: true)
  end
end
