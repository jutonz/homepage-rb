# typed: true

class IssueFormComponent < ApplicationComponent
  erb_template <<~ERB
    <%= helpers.simple_form_for(@issue) do |form| %>
      <%= form.input(:title, autofocus: true) %>
      <%= form.label(:description) %>
      <%= form.rich_text_area(:description) %>
      <%= form.button(:submit, class: "mt-4") %>
    <% end %>
  ERB

  sig { params(issue: Issue).void }
  def initialize(issue:)
    @issue = issue
  end
end
