# typed: true

class IssueStatusPillComponent < ApplicationComponent
  STATUS_COLORS = {
    "backlog" => :gray,
    "ready" => :blue,
    "in_progress" => :purple,
    "in_review" => :teal,
    "done" => :green,
    "cancelled" => :red
  }.freeze

  erb_template <<~ERB
    <%= render(PillComponent.new(
      text: Issue.statuses.fetch(@issue.status),
      color: STATUS_COLORS.fetch(@issue.status)
    )) %>
  ERB

  sig { params(issue: Issue).void }
  def initialize(issue:)
    @issue = issue
  end
end
