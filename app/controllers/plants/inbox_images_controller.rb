module Plants
  class InboxImagesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def index
      authorize(Plants::InboxImage)
      @inbox_images =
        policy_scope(Plants::InboxImage)
          .includes(:file_attachment)
          .order(taken_at: :desc)
    end
  end
end
