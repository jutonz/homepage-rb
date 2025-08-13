class InvitationsController < ApplicationController
  after_action :verify_authorized

  def show
    @invitation = authorize(find_invitation)
  end

  private

  def find_invitation
    UserGroupInvitation.find_by!(token: params[:token])
  end
end
