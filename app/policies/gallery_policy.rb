# typed: strict

class GalleryPolicy < UserOwnedPolicy
  Record = type_member { {fixed: Gallery} }
end
