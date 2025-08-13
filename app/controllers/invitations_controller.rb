class InvitationsController < ApplicationController
  after_action :verify_authorized

  def show
    @invitation = UserGroupInvitation.find_by!(token: params[:token])
    authorize(@invitation, :show?)

    if @invitation.expired?
      render :expired and return
    end

    if @invitation.accepted?
      render :already_accepted and return
    end

    # Show the invitation details for acceptance
  end
end
