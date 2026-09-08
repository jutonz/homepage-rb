# typed: true
# frozen_string_literal: true

class ApplicationPolicy
  extend T::Generic

  # `record` is polymorphic — each policy authorises a different model — so
  # the type travels with the subclass rather than being fixed here. Every
  # subclass pins it with `Record = type_member { {fixed: SomeModel} }`,
  # which is what makes a typo'd call on `record` a type error inside that
  # subclass.
  Record = type_member

  sig { returns(T.nilable(User)) }
  attr_reader :user

  sig { returns(Record) }
  attr_reader :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
