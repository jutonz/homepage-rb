class UserGroupsController < ApplicationController
  before_action :ensure_authenticated!
  after_action :verify_authorized

  def index
    authorize(UserGroup)
    @user_groups = policy_scope(UserGroup).order(:name)
  end

  def show
    @user_group = authorize(find_user_group)
    @pending_invitations = @user_group.user_group_invitations.pending.order(created_at: :desc)
    @new_invitation = UserGroupInvitation.new
  end

  def new
    @user_group = authorize(current_user.owned_user_groups.new)
  end

  def edit
    @user_group = authorize(find_user_group)
  end

  def create
    @user_group =
      UserGroupCreator
        .call(owner: current_user, params: user_group_params)
        .then { authorize(it) }

    if @user_group.persisted?
      redirect_to @user_group, notice: "User group was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @user_group = authorize(find_user_group)

    if @user_group.update(user_group_params)
      redirect_to @user_group, notice: "User group was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @user_group = authorize(find_user_group)
    @user_group.destroy!

    redirect_to(
      user_groups_path,
      status: :see_other,
      notice: "User group was successfully destroyed."
    )
  end

  private

  def find_user_group
    policy_scope(UserGroup).find(params[:id])
  end

  def user_group_params
    params.expect(user_group: [:name])
  end
end
