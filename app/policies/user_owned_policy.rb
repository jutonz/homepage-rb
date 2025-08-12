class UserOwnedPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user_owns_record?
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
    user.present? && owner == user
  end

  def owner
    record.user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none if user.blank?
      scope.where(user:)
    end
  end
end
