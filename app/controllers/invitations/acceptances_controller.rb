module Invitations
  class AcceptancesController < ApplicationController
    before_action :ensure_authenticated!

    def create
      @invitation = UserGroupInvitation.find_by!(token: params[:invitation_token])

      if @invitation.accept!
        redirect_to @invitation.user_group, notice: "Welcome to #{@invitation.user_group.name}!"
      elsif @invitation.expired?
        redirect_to invitation_path(@invitation.token), alert: "This invitation has expired."
      elsif @invitation.accepted?
        redirect_to @invitation.user_group, notice: "You're already a member of this group."
      else
        redirect_to invitation_path(@invitation.token), alert: "Unable to accept invitation. Please try again."
      end
    end
  end
end
