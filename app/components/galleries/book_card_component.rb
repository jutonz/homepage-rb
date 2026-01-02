module Galleries
  class BookCardComponent < ApplicationComponent
    erb_template <<~ERB
            <%= link_to(
              gallery_book_path(@gallery, @book),
              data: {role: "book"},
              class: "block p-4 border border-gray-300 rounded-lg \
      hover:border-gray-400 transition-colors"
            ) do %>
              <div class="flex justify-between items-center">
                <span class="font-medium text-gray-900">
                  <%= @book.name %>
                </span>
              </div>
            <% end %>
    ERB

    def initialize(book:)
      @book = book
      @gallery = book.gallery
    end
  end
end
