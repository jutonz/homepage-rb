require "rails_helper"
require Rails.root.join(
  "db/migrate/20261115120000_delete_existing_issues_and_add_project_id"
)

RSpec.describe DeleteExistingIssuesAndAddProjectId do
  after { Issue.reset_column_information }

  def connection
    ActiveRecord::Base.connection
  end

  def migrate(direction)
    ActiveRecord::Migration.suppress_messages do
      described_class.new.public_send(direction)
    end
    Issue.reset_column_information
  end

  def project_column
    connection.columns(:issues).find { it.name == "project_id" }
  end

  def count(table, where = "TRUE")
    connection.select_value("SELECT COUNT(*) FROM #{table} WHERE #{where}")
  end

  def insert_row(table, values)
    columns = values.keys.join(", ")
    quoted = values.values.map { connection.quote(it) }.join(", ")
    connection.select_value(
      "INSERT INTO #{table} (#{columns}) VALUES (#{quoted}) RETURNING id"
    )
  end

  def insert_blob(key)
    insert_row(
      :active_storage_blobs,
      key:,
      filename: "#{key}.txt",
      byte_size: 1,
      service_name: "test",
      created_at: Time.current
    )
  end

  def insert_rich_text(record_type, record_id)
    insert_row(
      :action_text_rich_texts,
      name: "description",
      record_type:,
      record_id:,
      created_at: Time.current,
      updated_at: Time.current
    )
  end

  def insert_attachment(record_type, record_id, blob_id)
    insert_row(
      :active_storage_attachments,
      name: "embeds",
      record_type:,
      record_id:,
      blob_id:,
      created_at: Time.current
    )
  end

  def insert_issue(user)
    insert_row(
      :issues,
      title: "Old",
      number: 1,
      user_id: user.id,
      created_at: Time.current,
      updated_at: Time.current
    )
  end

  def seed_issue_with_description(user)
    issue_id = insert_issue(user)
    rich_text_id = insert_rich_text("Issue", issue_id)
    insert_attachment(
      "ActionText::RichText",
      rich_text_id,
      insert_blob("issue-#{issue_id}")
    )
    rich_text_id
  end

  def seed_bystander_description
    rich_text_id = insert_rich_text("Gallery", 1)
    insert_attachment(
      "ActionText::RichText",
      rich_text_id,
      insert_blob("bystander")
    )
  end

  it "deletes every issue, description, and embedded attachment" do
    user = create(:user)
    migrate(:down)
    rich_text_ids = Array.new(2) { seed_issue_with_description(user) }
    insert_attachment(
      "Galleries::Image",
      rich_text_ids.first,
      insert_blob("collide")
    )
    seed_bystander_description

    migrate(:up)

    expect(count(:issues)).to eq(0)
    expect(count(:action_text_rich_texts, "record_type = 'Issue'")).to eq(0)
    expect(count(:action_text_rich_texts, "record_type = 'Gallery'")).to eq(1)
    expect(count(:active_storage_attachments)).to eq(2)
    expect(count(:active_storage_blobs)).to eq(4)
  end

  it "adds a required, indexed project_id with a foreign key" do
    migrate(:down)

    migrate(:up)

    foreign_key = connection.foreign_keys(:issues).find do
      it.column == "project_id"
    end
    expect(project_column.null).to be(false)
    expect(connection.index_exists?(:issues, :project_id)).to be(true)
    expect(foreign_key.to_table).to eq("issues_projects")
  end

  it "removes the column, index, and foreign key on rollback" do
    migrate(:down)

    foreign_keys = connection.foreign_keys(:issues).map(&:column)
    expect(project_column).to be_nil
    expect(connection.index_exists?(:issues, :project_id)).to be(false)
    expect(foreign_keys).not_to include("project_id")
  end
end
