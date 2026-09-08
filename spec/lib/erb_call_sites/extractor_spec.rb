require "rails_helper"
require Rails.root.join("lib/erb_call_sites/extractor").to_s

RSpec.describe ErbCallSites::Extractor do
  it "transcribes a component construction found in the template" do
    template = "<%= render(PillComponent.new(text: \"hi\")) %>\n"

    ruby = described_class.new(template:, source_path: "a/b.html.erb").to_ruby

    expect(ruby).to include("PillComponent.new(text: \"hi\")")
  end

  it "names the generated class after the template path" do
    template = "<%= render(PillComponent.new(text: \"hi\")) %>\n"

    ruby = described_class.new(
      template:,
      source_path: "app/views/todo/rooms/show.html.erb"
    ).to_ruby

    expect(ruby).to include("class TodoRoomsShow")
  end

  it "records the template path and line of each call site" do
    template = <<~ERB
      <div>
        <%= render(PillComponent.new(text: "hi")) %>
      </div>
    ERB

    ruby = described_class.new(
      template:,
      source_path: "app/views/todo/rooms/show.html.erb"
    ).to_ruby

    expect(ruby).to include("app/views/todo/rooms/show.html.erb:2")
  end

  it "declares bare identifiers as untyped locals" do
    template = "<%= render(Todo::TaskCardComponent.new(task:, room:)) %>\n"

    ruby = described_class.new(template:, source_path: "a/b.html.erb").to_ruby

    expect(ruby).to include("task = T.unsafe(nil)")
    expect(ruby).to include("room = T.unsafe(nil)")
  end

  it "declares block parameters as untyped locals" do
    template = <<~ERB
      <% @room.tasks.each do |task| %>
        <%= render(Todo::TaskCardComponent.new(task: task, room: @room)) %>
      <% end %>
    ERB

    ruby = described_class.new(template:, source_path: "a/b.html.erb").to_ruby

    expect(ruby).to include("task = T.unsafe(nil)")
  end

  it "keeps argument values rooted at an instance variable verbatim" do
    template = "<%= render(HeaderComponent.new(title: @room.name)) %>\n"

    ruby = described_class.new(template:, source_path: "a/b.html.erb").to_ruby

    expect(ruby).to include("HeaderComponent.new(title: @room.name)")
  end

  it "replaces argument values that call a view helper with T.unsafe(nil)" do
    template = "<%= render(HeaderComponent.new(title: t(\".title\"))) %>\n"

    ruby = described_class.new(template:, source_path: "a/b.html.erb").to_ruby

    expect(ruby).to include("HeaderComponent.new(title: T.unsafe(nil))")
    expect(ruby).not_to include("t(\".title\")")
  end

  it "keeps the keyword name when the value is replaced" do
    template = "<%= render(HeaderComponent.new(ttile: t(\".x\"))) %>\n"

    ruby = described_class.new(template:, source_path: "a/b.html.erb").to_ruby

    expect(ruby).to include("ttile:")
  end

  it "transcribes every call site in the template" do
    template = <<~ERB
      <%= render(PillComponent.new(text: "one")) %>
      <%= render(PillComponent.new(text: "two")) %>
    ERB

    ruby = described_class.new(template:, source_path: "a/b.html.erb").to_ruby

    expect(ruby).to include("text: \"one\"")
    expect(ruby).to include("text: \"two\"")
  end

  it "transcribes a construction that is not wrapped in render" do
    template = "<% c = PillComponent.new(text: \"hi\") %>\n"

    ruby = described_class.new(template:, source_path: "a/b.html.erb").to_ruby

    expect(ruby).to include("PillComponent.new(text: \"hi\")")
  end

  it "ignores constructions that are neither rendered nor components" do
    template = "<% form = Todo::RoomForm.new(room: @room) %>\n"

    ruby = described_class.new(template:, source_path: "a/b.html.erb").to_ruby

    expect(ruby).not_to include("Todo::RoomForm.new")
  end

  # A misspelling loses the naming convention, so `render` is the only
  # thing left that says "this is a component".
  it "transcribes a rendered construction whose name is misspelled" do
    template = "<%= render(PillComponnet.new(text: \"hi\")) %>\n"

    ruby = described_class.new(template:, source_path: "a/b.html.erb").to_ruby

    expect(ruby).to include("PillComponnet.new(text: \"hi\")")
  end

  it "reports no call sites for a template that renders no components" do
    template = "<div><%= @room.name %></div>\n"

    extractor = described_class.new(template:, source_path: "a/b.html.erb")

    expect(extractor.call_sites?).to be(false)
  end

  it "reports call sites for a template that renders a component" do
    template = "<%= render(PillComponent.new(text: \"hi\")) %>\n"

    extractor = described_class.new(template:, source_path: "a/b.html.erb")

    expect(extractor.call_sites?).to be(true)
  end

  it "produces Ruby that parses" do
    template = <<~ERB
      <%= render(HeaderComponent.new(title: @room.name)) do |header| %>
        <% header.with_crumb("Home", home_path) %>
      <% end %>

      <% @room.tasks.each do |task| %>
        <%= render(Todo::TaskCardComponent.new(task: task, room: @room)) %>
      <% end %>
    ERB

    ruby = described_class.new(template:, source_path: "a/b.html.erb").to_ruby

    expect(Prism.parse(ruby).success?).to be(true)
  end
end
