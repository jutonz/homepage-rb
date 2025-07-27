module Galleries
  class BackfillAutoTagsJob < ApplicationJob
    queue_as :default

    def perform(auto_add_tag)
      images_with_main_tag = auto_add_tag.tag.images

      images_with_main_tag.find_each do |image|
        image.add_tag(auto_add_tag.auto_add_tag)
      end
    end
  end
end
