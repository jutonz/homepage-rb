# typed: true

class IssueFormComponent < ApplicationComponent
  erb_template <<~ERB
    <%= helpers.simple_form_for(@issue) do |form| %>
      <%= form.input(:title, autofocus: true) %>
      <%= form.input(
        :status,
        collection: Issue.statuses.map { |key, label| [label, key] },
        include_blank: false,
        selected: selected_status
      ) %>
      <%= form.label(:description) %>
      <%= form.rich_text_area(:description) %>
      <%= form.button(:submit, class: "mt-4") %>
    <% end %>
  ERB

  sig { params(issue: Issue).void }
  def initialize(issue:)
    @issue = issue
  end

  private

  sig { returns(T.nilable(String)) }
  def selected_status
    if Issue.statuses.key?(@issue.status)
      @issue.status
    else
      @issue.status_in_database
    end
  end
end
