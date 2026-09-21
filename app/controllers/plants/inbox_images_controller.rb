# typed: strict

module Plants
  class InboxImagesController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    sig { void }
    def index
      authorize(Plants::InboxImage)
      @inbox_images = T.let(
        Plants::InboxImagePolicy.scope_for(current_user)
          .includes(:file_attachment)
          .order(taken_at: :desc),
        T.nilable(
          T.all(ActiveRecord::Relation, T::Enumerable[Plants::InboxImage])
        )
      )
    end

    sig { void }
    def new
      @inbox_image = T.let(
        authorize(current_user.plants_inbox_images.new),
        T.nilable(Plants::InboxImage)
      )
    end

    sig { void }
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

      inbox_image = T.must(result.inbox_image)
      @inbox_image = inbox_image
      flash.now[:alert] = inbox_image.errors.full_messages.to_sentence
      render(:new, status: :unprocessable_content)
    end

    sig { void }
    def show
      @inbox_image = authorize(find_inbox_image)
      @plants = T.let(
        Plants::PlantPolicy.scope_for(current_user)
          .includes(key_image: :file_attachment)
          .order(:name),
        T.nilable(T.all(ActiveRecord::Relation, T::Enumerable[Plants::Plant]))
      )
    end

    sig { void }
    def destroy
      inbox_image = find_inbox_image
      @inbox_image = authorize(inbox_image)
      inbox_image.destroy!
      redirect_to(inbox_images_path, notice: "Image was deleted.")
    end

    private

    sig { returns(Plants::InboxImage) }
    def find_inbox_image
      Plants::InboxImagePolicy.scope_for(current_user).find(params[:id])
    end

    sig { returns(ActionController::Parameters) }
    def inbox_image_params
      params.expect(plants_inbox_image: [:taken_at, :file, {file: []}])
    end
  end
end
