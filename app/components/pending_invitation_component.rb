class PendingInvitationComponent < ApplicationComponent
  erb_template <<~ERB
    <div class="flex justify-between items-center p-3 bg-gray-50 rounded-md" data-role="pending-invitation">
      <div class="flex-1">
        <div class="font-medium text-gray-900"><%= @invitation.email %></div>
        <div class="text-sm text-gray-500">
          Sent <%= time_ago_in_words(@invitation.created_at) %> ago
          <% if @invitation.expired? %>
            • <span class="text-red-600 font-medium">Expired</span>
          <% else %>
            • Expires <%= time_ago_in_words(@invitation.expires_at) %>
          <% end %>
        </div>
      </div>
      <div class="flex items-center space-x-2">
        <% unless @invitation.expired? %>
          <%= render(PillComponent.new(
            text: "Pending",
            color: :yellow
          )) %>
        <% else %>
          <%= render(PillComponent.new(
            text: "Expired",
            color: :red
          )) %>
        <% end %>
        <%= button_to(
          "Cancel",
          user_group_invitation_path(@invitation.user_group, @invitation),
          method: :delete,
          data: {turbo_confirm: "Are you sure you want to cancel this invitation?"},
          class: "px-2 py-1 text-xs bg-red-100 text-red-700 rounded hover:bg-red-200 focus:outline-none focus:ring-1 focus:ring-red-500"
        ) %>
      </div>
    </div>
  ERB

  def initialize(invitation:)
    @invitation = invitation
  end
end
