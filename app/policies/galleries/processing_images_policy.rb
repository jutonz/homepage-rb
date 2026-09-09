# typed: true

module Galleries
  class ProcessingImagesPolicy < UserOwnedPolicy
    Record = type_member { {fixed: Gallery} }

    # This policy governs a gallery, so its name does not name its model.
    sig { returns(T.class_of(ActiveRecord::Base)) }
    def self.model = Gallery
  end
end
