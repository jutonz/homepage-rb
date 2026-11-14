require "rails_helper"

RSpec.describe IssueStatusPillComponent, type: :component do
  {
    "backlog" => ["gray", "Backlog"],
    "ready" => ["blue", "Ready"],
    "in_progress" => ["purple", "In Progress"],
    "in_review" => ["teal", "In Review"],
    "done" => ["green", "Done"],
    "cancelled" => ["red", "Cancelled"]
  }.each do |status, (color, label)|
    it "renders a #{color} pill labelled #{label} for #{status}" do
      issue = build_stubbed(:issue, status:)

      render_inline(described_class.new(issue:))

      expect(page).to have_css(
        "span.bg-#{color}-100.text-#{color}-800",
        text: label,
        exact_text: true,
        normalize_ws: true
      )
    end
  end
end
