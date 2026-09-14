# typed: strict

class RecipeGroupPolicy < ApplicationPolicy
  Record = type_member { {fixed: RecipeGroup} }

  sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
  def self.scope_for(user)
    return model.none if user.blank?

    owned_ids = model.where(owner: user).pluck(:id)
    shared_ids = model.joins(user_groups: :users)
      .where(users: {id: user.id})
      .pluck(:id)

    model.where(id: owned_ids + shared_ids)
  end

  sig { returns(T::Boolean) }
  def index?
    user.present?
  end

  sig { returns(T::Boolean) }
  def show?
    user_has_access?
  end

  sig { returns(T::Boolean) }
  def create?
    user.present?
  end

  sig { returns(T::Boolean) }
  def new?
    user.present?
  end

  sig { returns(T.nilable(T::Boolean)) }
  def edit?
    user_owns_record?
  end

  sig { returns(T.nilable(T::Boolean)) }
  def update?
    user_owns_record?
  end

  sig { returns(T.nilable(T::Boolean)) }
  def destroy?
    user_owns_record?
  end

  private

  sig { returns(T.nilable(T::Boolean)) }
  def user_owns_record?
    user && record.owner == user
  end

  sig { returns(T::Boolean) }
  def user_has_access?
    return false unless user

    user_owns_record? || user_has_shared_access?
  end

  sig { returns(T::Boolean) }
  def user_has_shared_access?
    return false unless record.user_groups.any?

    record.user_groups.any? { |user_group| user_group.users.include?(user) }
  end
end
