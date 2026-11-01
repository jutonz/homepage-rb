# typed: true

module Issues
  class ProjectFormComponent < ApplicationComponent
    erb_template <<~ERB
      <%= helpers.simple_form_for(@project) do |form| %>
        <%= form.input(:name, autofocus: true) %>
        <%= form.input(:key) %>
        <%= form.button(:submit, class: "mt-4") %>
      <% end %>
    ERB

    sig { params(project: Issues::Project).void }
    def initialize(project:)
      @project = project
    end
  end
end
