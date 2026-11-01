require "rails_helper"

# == Schema Information
#
# Table name: issues_projects
# Database name: primary
#
#  id         :bigint           not null, primary key
#  key        :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_issues_projects_on_user_id_and_lower_key   (user_id, lower((key)::text)) UNIQUE
#  index_issues_projects_on_user_id_and_lower_name  (user_id, lower((name)::text)) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe Issues::Project do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_length_of(:name).is_at_most(255) }
  it { is_expected.to normalize(:name).from("  Infra  ").to("Infra") }
  it { is_expected.to normalize(:key).from("  INFRA  ").to("INFRA") }
  it { is_expected.to normalize(:name).from(nil).to(nil) }

  describe "uniqueness" do
    subject { build(:issues_project) }

    it do
      is_expected.to validate_uniqueness_of(:name)
        .scoped_to(:user_id).case_insensitive
    end

    it do
      is_expected.to validate_uniqueness_of(:key)
        .scoped_to(:user_id).case_insensitive
    end
  end

  it do
    is_expected.to have_db_index("user_id, lower((name)::text)").unique
  end

  it do
    is_expected.to have_db_index("user_id, lower((key)::text)").unique
  end

  it "has a valid factory" do
    expect(build(:issues_project)).to be_valid
  end

  it "rejects a name of only spaces" do
    project = build(:issues_project, name: "   ")

    expect(project).not_to be_valid
    expect(project.errors[:name]).to include("can't be blank")
  end

  it "keeps the case and characters of the key" do
    key = "In-fra  x/1 ✓#{"z" * 300}"
    project = create(:issues_project, key: " #{key} ")

    expect(project.reload.key).to eq(key)
  end

  it "rejects a name that differs only in case and spaces" do
    existing = create(:issues_project, name: "Infra")
    project = build(:issues_project, user: existing.user, name: " INFRA ")

    expect(project).not_to be_valid
    expect(project.errors[:name]).to include("has already been taken")
  end

  it "rejects a rename to a name that differs only in case from mine" do
    existing = create(:issues_project, name: "Infra")
    project = create(:issues_project, user: existing.user, name: "Homepage")

    project.name = "INFRA"

    expect(project).not_to be_valid
    expect(project.errors[:name]).to include("has already been taken")
  end

  it "allows the same name and key for another user" do
    existing = create(:issues_project, name: "Infra", key: "INF")
    project = build(:issues_project, name: "Infra", key: "INF")

    expect(project).to be_valid
    expect(existing.user).not_to eq(project.user)
  end

  it "enforces case-insensitive name uniqueness in the database" do
    existing = create(:issues_project, name: "Infra")
    project = build(:issues_project, user: existing.user, name: "INFRA")

    expect { project.save!(validate: false) }
      .to raise_error(ActiveRecord::RecordNotUnique, /lower_name/)
  end

  it "enforces case-insensitive key uniqueness in the database" do
    existing = create(:issues_project, key: "inf")
    project = build(:issues_project, user: existing.user, key: "INF")

    expect { project.save!(validate: false) }
      .to raise_error(ActiveRecord::RecordNotUnique, /lower_key/)
  end
end
