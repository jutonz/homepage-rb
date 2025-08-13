class InvitationsController < ApplicationController
  def show
    @invitation = UserGroupInvitation.find_by!(token: params[:token])
    # in thie show view, handle the otken being expired or already accepted
    # Show the invitation details for acceptance
  end
end
