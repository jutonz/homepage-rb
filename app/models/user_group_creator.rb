class UserGroupCreator
  attr_reader :owner, :params, :user_group

  def self.call(owner:, **params)
    new(owner:, params:).call
  end

  def initialize(owner:, params:)
    @owner = owner
    @params = params
  end

  def call
    UserGroup.transaction do
      create_user_group
      create_owner_membership
    end
    self
  end

  def success?
    user_group&.persisted? && user_group.errors.empty?
  end

  private

  def create_user_group
    @user_group = owner.owned_user_groups.create(params)
  end

  def create_owner_membership
    return unless user_group.persisted?

    user_group.user_group_memberships.create!(user: owner)
  end
end
