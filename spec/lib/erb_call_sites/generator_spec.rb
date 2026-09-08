require "rails_helper"
require Rails.root.join("lib/erb_call_sites/generator").to_s

RSpec.describe ErbCallSites::Generator do
  def in_project
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, "app/views/todo/rooms"))
      yield(Pathname.new(root))
    end
  end

  def generator_for(root)
    described_class.new(
      root:,
      sources: ["app/views/todo"],
      output: "sorbet/erb_call_sites"
    )
  end

  def write_template(root, path, contents)
    full = root.join(path)
    FileUtils.mkdir_p(full.dirname)
    full.write(contents)
  end

  it "writes a transcription mirroring the template path" do
    in_project do |root|
      write_template(
        root,
        "app/views/todo/rooms/show.html.erb",
        "<%= render(PillComponent.new(text: \"hi\")) %>\n"
      )

      generator_for(root).generate

      expect(root.join("sorbet/erb_call_sites/todo/rooms/show.rb")).to exist
    end
  end

  it "writes the transcribed construction into that file" do
    in_project do |root|
      write_template(
        root,
        "app/views/todo/rooms/show.html.erb",
        "<%= render(PillComponent.new(text: \"hi\")) %>\n"
      )

      generator_for(root).generate

      contents = root.join("sorbet/erb_call_sites/todo/rooms/show.rb").read
      expect(contents).to include("PillComponent.new(text: \"hi\")")
    end
  end

  it "writes nothing for a template that renders no components" do
    in_project do |root|
      write_template(
        root,
        "app/views/todo/rooms/show.html.erb",
        "<div><%= @room.name %></div>\n"
      )

      generator_for(root).generate

      expect(root.join("sorbet/erb_call_sites/todo")).not_to exist
    end
  end

  it "reports nothing stale right after generating" do
    in_project do |root|
      write_template(
        root,
        "app/views/todo/rooms/show.html.erb",
        "<%= render(PillComponent.new(text: \"hi\")) %>\n"
      )
      generator = generator_for(root)
      generator.generate

      expect(generator.stale).to be_empty
    end
  end

  it "reports a template whose transcription is out of date" do
    in_project do |root|
      write_template(
        root,
        "app/views/todo/rooms/show.html.erb",
        "<%= render(PillComponent.new(text: \"hi\")) %>\n"
      )
      generator = generator_for(root)
      generator.generate

      write_template(
        root,
        "app/views/todo/rooms/show.html.erb",
        "<%= render(PillComponent.new(text: \"bye\")) %>\n"
      )

      expect(generator.stale)
        .to eq(["sorbet/erb_call_sites/todo/rooms/show.rb"])
    end
  end

  it "reports a transcription whose template is gone" do
    in_project do |root|
      write_template(
        root,
        "app/views/todo/rooms/show.html.erb",
        "<%= render(PillComponent.new(text: \"hi\")) %>\n"
      )
      generator = generator_for(root)
      generator.generate
      root.join("app/views/todo/rooms/show.html.erb").delete

      expect(generator.stale)
        .to eq(["sorbet/erb_call_sites/todo/rooms/show.rb"])
    end
  end

  it "deletes a transcription whose template is gone" do
    in_project do |root|
      write_template(
        root,
        "app/views/todo/rooms/show.html.erb",
        "<%= render(PillComponent.new(text: \"hi\")) %>\n"
      )
      generator = generator_for(root)
      generator.generate
      root.join("app/views/todo/rooms/show.html.erb").delete

      generator.generate

      expect(root.join("sorbet/erb_call_sites/todo/rooms/show.rb")).not_to exist
    end
  end

  it "transcribes a template whose format is not html" do
    in_project do |root|
      write_template(
        root,
        "app/views/todo/rooms/show.turbo_stream.erb",
        "<%= render(PillComponent.new(text: \"hi\")) %>\n"
      )

      generator_for(root).generate

      expect(root.join("sorbet/erb_call_sites/todo/rooms/show.turbo_stream.rb"))
        .to exist
    end
  end

  # `_show.html.erb` and `show.html.erb` both want todo/rooms/show.rb.
  # Silently keeping one of them would leave `stale` unable to settle.
  it "refuses to generate when two templates claim the same path" do
    in_project do |root|
      ["show.html.erb", "_show.html.erb"].each do |name|
        write_template(
          root,
          "app/views/todo/rooms/#{name}",
          "<%= render(PillComponent.new(text: \"hi\")) %>\n"
        )
      end

      expect { generator_for(root).generate }
        .to raise_error(described_class::CollidingTemplates, /show\.rb/)
    end
  end

  it "transcribes partials as well as full templates" do
    in_project do |root|
      write_template(
        root,
        "app/views/todo/rooms/_task_card.html.erb",
        "<%= render(PillComponent.new(text: \"hi\")) %>\n"
      )

      generator_for(root).generate

      expect(root.join("sorbet/erb_call_sites/todo/rooms/task_card.rb"))
        .to exist
    end
  end
end
