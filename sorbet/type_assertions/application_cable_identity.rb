# typed: strict
# frozen_string_literal: true

# A spec passes with `T.untyped` as it does with `User`.
# `T.assert_type!` checks that the shim provides the narrow type.
# This file must not load at runtime, so it lives under `sorbet/`.
#
# Sorbet gives an assignment expression the type of the right side, not
# the return type of the setter. `T.assert_type!` on `current_user =`
# therefore tests the argument, not the shim. The bare call below holds
# the setter in the guard instead.
module ApplicationCableIdentityTypeAssertions
  extend T::Sig

  sig do
    params(
      channel: Galleries::ProcessingImagesChannel,
      connection: ApplicationCable::Connection,
      user: User
    ).void
  end
  def self.assertions(channel, connection, user)
    T.assert_type!(channel.current_user, User)
    T.assert_type!(connection.current_user, User)
    connection.current_user = user
  end
end
