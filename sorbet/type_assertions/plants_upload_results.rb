# typed: strict
# frozen_string_literal: true

# The shim in sorbet/rbi/shims/plants_upload_results.rbi gives a static
# guarantee that rspec cannot see: a spec passes against `T.untyped` as
# it passes against the concrete image type. This file asserts the
# guarantee instead. `bin/srb tc` fails if that shim no longer narrows.
#
# This file must never load, so it lives under sorbet/.
#
# Positive assertions catch a shim that goes wide. `T.assert_type!`
# rejects `T.untyped` as firmly as it rejects a wrong type.
module PlantsUploadResultsTypeAssertions
  extend T::Sig

  sig do
    params(
      plant: Plants::PlantImageUpload::Result,
      inbox: Plants::InboxImageUpload::Result
    ).void
  end
  def self.assertions(plant, inbox)
    T.assert_type!(plant.saved, T::Boolean)
    T.assert_type!(plant.plant_image, T.nilable(Plants::PlantImage))
    T.assert_type!(inbox.saved, T::Boolean)
    T.assert_type!(inbox.inbox_image, T.nilable(Plants::InboxImage))
  end
end
