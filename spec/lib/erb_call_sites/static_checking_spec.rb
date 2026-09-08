require "rails_helper"
require Rails.root.join("lib/erb_call_sites/extractor").to_s

# The point of the whole exercise: a wrong component argument written in a
# template is rejected by Sorbet, not left for the page render to discover.
# These examples run the real type checker over the generated transcription.
RSpec.describe "static checking of ERB component call sites" do
  # Runs the real type checker over the transcription of `template` and
  # returns only the errors Sorbet attributed to it, so an unrelated
  # error elsewhere in the project cannot make these examples lie.
  #
  # The two examples below that expect no errors would otherwise pass just
  # as happily if nothing ran at all, so this refuses to return a verdict
  # unless the transcription carried a call site and Sorbet really spoke.
  def sorbet_errors_for(template)
    ruby = ErbCallSites::Extractor.new(
      template:,
      source_path: "spec/fixtures/example.html.erb"
    ).to_ruby

    unless ruby.include?(".new(")
      raise("nothing transcribed from the template")
    end

    file = Tempfile.new(["erb_call_site", ".rb"])
    file.write(ruby)
    file.close
    path = file.path

    output = Dir.chdir(Rails.root) do
      `bin/srb tc #{path} 2>&1`
    end

    file.unlink
    raise("sorbet said nothing: #{output}") unless output.match?(/error|Errors/i)

    output.split("\n\n").select { it.start_with?(path) }.join("\n\n")
  end

  it "accepts a template that constructs a component correctly" do
    template = <<~ERB
      <% @room.tasks.each do |task| %>
        <%= render(Todo::TaskCardComponent.new(task: task, room: @room)) %>
      <% end %>
    ERB

    errors = sorbet_errors_for(template)

    expect(errors).to eq("")
  end

  it "rejects a template that misspells a keyword argument" do
    template = <<~ERB
      <%= render(Todo::TaskCardComponent.new(tsak: @task, room: @room)) %>
    ERB

    errors = sorbet_errors_for(template)

    expect(errors).to include("Unrecognized keyword argument `tsak`")
  end

  it "rejects a template that omits a required keyword argument" do
    template = <<~ERB
      <%= render(Todo::TaskCardComponent.new(room: @room)) %>
    ERB

    errors = sorbet_errors_for(template)

    expect(errors).to include("Missing required keyword argument `task`")
  end

  it "rejects a template that names a component that does not exist" do
    template = <<~ERB
      <%= render(Todo::TaskCardComponnet.new(task: @task, room: @room)) %>
    ERB

    errors = sorbet_errors_for(template)

    expect(errors).to include("Unable to resolve constant")
  end

  it "rejects a template that passes a literal of the wrong type" do
    template = <<~ERB
      <%= render(PillComponent.new(text: "hi", color: "blue")) %>
    ERB

    errors = sorbet_errors_for(template)

    expect(errors).to include("Expected `Symbol` but found `String(\"blue\")`")
  end

  # The limitation this ticket set out to measure. Swapping two model
  # arguments is still invisible, because the ivars a template reads have
  # no declared type -- see docs/adr/0001-erb-call-site-typing.md.
  it "does not catch a swapped argument whose value is an untyped ivar" do
    template = <<~ERB
      <%= render(Todo::TaskCardComponent.new(task: @room, room: @task)) %>
    ERB

    errors = sorbet_errors_for(template)

    expect(errors).to eq("")
  end
end
