module Plants
  class PlantPolicy < UserOwnedPolicy
    private

    def owner
      record.added_by
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none if user.blank?

        scope.where(added_by: user)
      end
    end
  end
end
