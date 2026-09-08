# typed: true

module Galleries
  class ProcessingImagesPolicy < UserOwnedPolicy
    Record = type_member { {fixed: Gallery} }
  end
end
