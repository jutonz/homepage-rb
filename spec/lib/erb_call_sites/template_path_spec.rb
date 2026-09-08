require "rails_helper"
require Rails.root.join("lib/erb_call_sites/template_path").to_s

RSpec.describe ErbCallSites::TemplatePath do
  it "names the transcription after the path below app/views" do
    path = described_class.new("app/views/todo/rooms/show.html.erb")

    expect(path.class_name).to eq("TodoRoomsShow")
  end

  it "drops the leading underscore of a partial" do
    path = described_class.new("app/views/todo/rooms/_task_card.html.erb")

    expect(path.class_name).to eq("TodoRoomsTaskCard")
  end

  it "places the transcription alongside its template" do
    path = described_class.new("app/views/todo/rooms/show.html.erb")

    expect(path.relative_path).to eq("todo/rooms/show.rb")
  end

  it "places a partial's transcription without the underscore" do
    path = described_class.new("app/views/todo/rooms/_task_card.html.erb")

    expect(path.relative_path).to eq("todo/rooms/task_card.rb")
  end

  # Keeping the format keeps show.html.erb and show.turbo_stream.erb from
  # both claiming todo/rooms/show.rb.
  it "keeps a non-html format in the transcription path" do
    path = described_class.new("app/views/todo/rooms/show.turbo_stream.erb")

    expect(path.relative_path).to eq("todo/rooms/show.turbo_stream.rb")
  end

  it "keeps a non-html format in the class name" do
    path = described_class.new("app/views/todo/rooms/show.turbo_stream.erb")

    expect(path.class_name).to eq("TodoRoomsShowTurboStream")
  end
end
