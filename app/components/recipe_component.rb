class RecipeComponent < ApplicationComponent
  erb_template <<~ERB
    <%= link_to(
      recipe_group_recipe_path(@recipe_group, @recipe),
      data: {role: "recipe"},
      class: "block p-4 border border-gray-200 rounded-lg hover:bg-gray-50 hover:border-gray-300 transition-colors duration-200 group"
    ) do %>
      <div class="flex justify-between items-center mb-2">
        <span class="font-medium text-gray-900 group-hover:text-gray-700"><%= @recipe.name %></span>
      </div>
      <% if @recipe.description.present? %>
        <div class="text-sm text-gray-600 mb-2 line-clamp-2">
          <%= @recipe.description %>
        </div>
      <% end %>
    <% end %>
  ERB

  def initialize(recipe:, recipe_group:)
    @recipe = recipe
    @recipe_group = recipe_group
  end
end
