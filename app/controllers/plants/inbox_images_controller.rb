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

    def new
      @inbox_image = authorize(current_user.plants_inbox_images.new)
    end

    def create
      authorize(Plants::InboxImage.new(user: current_user))
      result = Plants::InboxImageUpload.new(
        user: current_user,
        files: inbox_image_params[:file],
        taken_at: inbox_image_params[:taken_at]
      ).save

      if result.saved?
        redirect_to(inbox_images_path, notice: "Images were added.")
        return
      end

      @inbox_image = result.inbox_image
      flash.now[:alert] =
        @inbox_image.errors.full_messages.to_sentence
      render(:new, status: :unprocessable_content)
    end

    def show
      @inbox_image = authorize(find_inbox_image)
    end

    def destroy
      @inbox_image = authorize(find_inbox_image)
      @inbox_image.destroy!
      redirect_to(inbox_images_path, notice: "Image was deleted.")
    end

    private

    def find_inbox_image
      policy_scope(Plants::InboxImage).find(params[:id])
    end

    def inbox_image_params
      params.expect(plants_inbox_image: [:taken_at, :file, {file: []}])
    end
  end
end
