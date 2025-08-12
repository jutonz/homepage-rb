class UserGroupCreator
  def self.call(...) = new(...).call

  def initialize(owner:, params:)
    @owner = owner
    @params = params
  end

  def call
    user_group = owner.owned_user_groups.build(params)
    UserGroup.transaction do
      user_group.save!
      user_group.user_group_memberships.create!(user: owner)
      user_group
    end
  rescue ActiveRecord::RecordInvalid
    user_group
  end

  private

  attr_reader :owner
  attr_reader :params
end
