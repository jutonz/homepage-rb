class UserGroupDetailsComponent < ApplicationComponent
  erb_template <<~ERB
    <div class="bg-white rounded-lg border border-gray-200 p-6">
      <h3 class="text-lg font-semibold mb-4">Group Details</h3>

      <div class="space-y-3">
        <div>
          <span class="font-medium text-gray-700">Name:</span>
          <span class="ml-2"><%= @user_group.name %></span>
        </div>

        <div>
          <span class="font-medium text-gray-700">Owner:</span>
          <span class="ml-2"><%= @user_group.owner.email %></span>
        </div>

        <div>
          <span class="font-medium text-gray-700">Created:</span>
          <span class="ml-2"><%= @user_group.created_at.strftime("%B %d, %Y") %></span>
        </div>

        <div>
          <span class="font-medium text-gray-700">Members:</span>
          <span class="ml-2"><%= @user_group.users_count %></span>
        </div>
      </div>
    </div>
  ERB

  def initialize(user_group:)
    @user_group = user_group
  end
end
