module UserGroups
  class InvitationsController < ApplicationController
    before_action :ensure_authenticated!
    after_action :verify_authorized

    def create
      @user_group = find_user_group
      authorize(UserGroupInvitation.new(user_group: @user_group))

      @invitation = UserGroupInvitationCreator.call(
        user_group: @user_group,
        email: invitation_params[:email],
        invited_by: current_user
      )

      if @invitation.persisted?
        UserGroupInvitationMailer.invitation(@invitation).deliver_later

        redirect_to @user_group, notice: "Invitation sent to #{@invitation.email}."
      else
        redirect_to @user_group, alert: "Failed to send invitation: #{@invitation.errors.full_messages.join(", ")}"
      end
    end

    def destroy
      @user_group = find_user_group
      @invitation = authorize(find_invitation)

      @invitation.destroy!

      redirect_to(
        @user_group,
        status: :see_other,
        notice: "Invitation to #{@invitation.email} has been cancelled."
      )
    end

    private

    def find_user_group
      policy_scope(UserGroup).find(params[:user_group_id])
    end

    def find_invitation
      @user_group.user_group_invitations.find(params[:id])
    end

    def invitation_params
      params.expect(user_group_invitation: [:email])
    end
  end
end
