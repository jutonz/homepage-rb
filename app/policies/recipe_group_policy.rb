class RecipeGroupPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user_has_access?
  end

  def create?
    user.present?
  end

  def new?
    user.present?
  end

  def edit?
    user_owns_record?
  end

  def update?
    user_owns_record?
  end

  def destroy?
    user_owns_record?
  end

  private

  def user_owns_record?
    user && record.owner == user
  end

  def user_has_access?
    return false unless user

    user_owns_record? || user_has_shared_access?
  end

  def user_has_shared_access?
    return false unless record.user_groups.any?

    record.user_groups.any? { |user_group| user_group.users.include?(user) }
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none if user.blank?

      owned_ids = scope.where(owner: user).pluck(:id)
      shared_ids = scope.joins(user_groups: :users)
        .where(users: {id: user.id})
        .pluck(:id)

      scope.where(id: owned_ids + shared_ids)
    end
  end
end
