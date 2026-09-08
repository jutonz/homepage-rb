# typed: true

class GalleryPolicy < UserOwnedPolicy
  Record = type_member { {fixed: Gallery} }
end
