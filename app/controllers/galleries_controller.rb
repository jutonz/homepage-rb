class GalleriesController < ApplicationController
  before_action :ensure_authenticated!

  def index
    @galleries = current_user.galleries.visible
  end

  PER_PAGE = 20
  def show
    @gallery = find_gallery
    @filter_tags = find_filter_tags
    @images =
      @gallery
        .images
        .includes(:file_attachment)
        .order(created_at: :desc)
        .then { @filter_tags.any? ? it.by_tags(@filter_tags) : it }
        .page(params[:page])
        .per(PER_PAGE)
    @tag_search = Galleries::TagSearch.new(
      gallery: @gallery,
      query: params.dig(:tag_search, :query)
    )
  end

  def new
    @gallery = current_user.galleries.new
  end

  def edit
    @gallery = find_gallery
  end

  def create
    @gallery = current_user.galleries.new(gallery_params)

    if @gallery.save
      redirect_to @gallery, notice: "Gallery was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @gallery = find_gallery

    if @gallery.update(gallery_params)
      redirect_to @gallery, notice: "Gallery was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @gallery = find_gallery
    @gallery.destroy!

    redirect_to(
      galleries_path,
      status: :see_other,
      notice: "Gallery was successfully destroyed."
    )
  end

  private

  def find_gallery
    current_user.galleries.find(params[:id])
  end

  def gallery_params
    params
      .require(:gallery)
      .permit(:name, :hidden_at)
      .tap do |params|
        params[:hidden_at] =
          if ActiveModel::Type::Boolean.new.cast(params[:hidden_at]).present?
            Time.current
          end
      end
  end

  def find_filter_tags
    ids = params.fetch(:tag_ids, [])
    @gallery.tags.where(id: ids)
  end
end
