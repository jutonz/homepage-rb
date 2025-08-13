class InvitationsController < ApplicationController
  after_action :verify_authorized

  def show
    @invitation = UserGroupInvitation.find_by!(token: params[:token])
    authorize(@invitation, :show?)
  end
end
