# typed: true

module Plants
  class PlantPolicy < UserOwnedPolicy
    Record = type_member { {fixed: Plants::Plant} }
  end
end
