# typed: strict

# `identified_by` creates these methods at runtime. Tapioca has no compiler
# for this Action Cable DSL, so Sorbet cannot see the methods.
class ApplicationCable::Connection
  sig { returns(User) }
  def current_user; end

  sig { params(value: User).returns(User) }
  def current_user=(value); end
end

class ApplicationCable::Channel
  sig { returns(User) }
  def current_user; end
end
