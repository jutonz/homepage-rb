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

      UserGroupInvitationMailer.invitation(@invitation).deliver_later

      redirect_to @user_group, notice: "Invitation sent to #{@invitation.email}."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to @user_group, alert: "Failed to send invitation: #{e.record.errors.full_messages.join(", ")}"
    end

    private

    def find_user_group
      policy_scope(UserGroup).find(params[:user_group_id])
    end

    def invitation_params
      params.expect(user_group_invitation: [:email])
    end
  end
end
