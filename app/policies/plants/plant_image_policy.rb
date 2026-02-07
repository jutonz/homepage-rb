module Plants
  class PlantImagePolicy < ApplicationPolicy
    def new?
      plant_owner?()
    end

    def create?
      plant_owner?()
    end

    def destroy?
      plant_owner?()
    end

    private

    def plant_owner?
      user.present?() && record.plant().user() == user
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none() if user.blank?()

        scope.joins(:plant).where(plants_plants: {user:})
      end
    end
  end
end
