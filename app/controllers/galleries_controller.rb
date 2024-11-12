class GalleriesController < ApplicationController
  before_action :ensure_authenticated!

  def index
    @galleries = current_user.galleries
  end

  def show
    @gallery = find_gallery
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
    params.require(:gallery).permit(:name)
  end
end
