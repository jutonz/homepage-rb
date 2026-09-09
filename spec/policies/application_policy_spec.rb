require "rails_helper"

# These policies govern no ActiveRecord model, so they have no policy
# scope to derive. The bulk-action policies authorize a plain form
# object, and `UserOwnedPolicy` is the abstract base that the
# owner-filtered policies share. Every other policy must name its model
# or override `.model`.
model_less_policies = [
  Galleries::BulkDeletePolicy,
  Galleries::BulkTagPolicy,
  Galleries::BulkUploadPolicy,
  UserOwnedPolicy
]

RSpec.describe ApplicationPolicy do
  describe ".model" do
    it "derives the model from the policy class name" do
      expect(GalleryPolicy.model).to eq(Gallery)
    end

    it "derives a namespaced model from a namespaced policy" do
      expect(Galleries::ImagePolicy.model).to eq(Galleries::Image)
    end

    it "uses the override when the name does not map to a model" do
      expect(Galleries::Books::ReadPolicy.model).to eq(Galleries::Book)
    end

    # A policy whose name does not name its model resolves to nothing, or
    # to the wrong thing. This example catches that in CI. Without it, the
    # first sign of a bad name is a failed request.
    it "resolves for every policy that governs a model" do
      Rails.application.eager_load!
      policies = ApplicationPolicy.descendants - model_less_policies

      unresolved = policies.filter_map do |policy|
        policy.model
        nil
      rescue => error
        "#{policy}: #{error.message}"
      end

      expect(unresolved).to be_empty
    end
  end

  describe ".scope_for" do
    it "raises unless the policy defines one" do
      expect { described_class.scope_for(build(:user)) }
        .to raise_error(NoMethodError, /must define \.scope_for/)
    end
  end
end
