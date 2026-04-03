module Galleries
  class ProcessingImagesPolicy < ApplicationPolicy
    def show?
      user && record.user == user
    end
  end
end
