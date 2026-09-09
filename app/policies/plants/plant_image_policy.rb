# typed: true

module Plants
  class PlantImagePolicy < ApplicationPolicy
    Record = type_member { {fixed: Plants::PlantImage} }

    sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
    def self.scope_for(user)
      return model.none if user.blank?

      model.joins(:plant).where(plants_plants: {user:})
    end

    def new?
      plant_owner?
    end

    def create?
      plant_owner?
    end

    def destroy?
      plant_owner?
    end

    def show?
      plant_owner?
    end

    def edit?
      plant_owner?
    end

    def update?
      plant_owner?
    end

    private

    def plant_owner?
      user.present? && record.plant&.user == user
    end
  end
end
