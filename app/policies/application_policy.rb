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

  # Override this where a policy's name does not name its model. Do not
  # make the derivation smarter — that changes what every other policy
  # resolves to.
  sig { returns(T.class_of(ActiveRecord::Base)) }
  def self.model
    T.must(name).delete_suffix("Policy").constantize
  end

  # Each bespoke `scope_for` copies its `Scope#resolve` word for word,
  # blank-user guard included, so that a reader can compare the two by
  # eye. Do not tidy the guards or merge the duplicate queries until
  # HPRB-48 deletes the `Scope` classes. See ADR 0001.
  sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
  def self.scope_for(user)
    raise NoMethodError, "You must define .scope_for in #{self}"
  end

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
