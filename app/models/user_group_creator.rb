# typed: strict

class UserGroupCreator
  Params =
    T.type_alias {
      T.any(ActionController::Parameters, T::Hash[Symbol, T.untyped])
    }

  sig { params(owner: User, params: Params).returns(UserGroup) }
  def self.call(owner:, params:) = new(owner:, params:).call

  sig { params(owner: User, params: Params).void }
  def initialize(owner:, params:)
    @owner = owner
    @params = params
  end

  sig { returns(UserGroup) }
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

  sig { returns(User) }
  attr_reader :owner

  sig { returns(Params) }
  attr_reader :params
end
