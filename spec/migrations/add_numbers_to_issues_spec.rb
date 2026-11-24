require "rails_helper"
require Rails.root.join("db/migrate/20261121120000_add_numbers_to_issues")

RSpec.describe AddNumbersToIssues do
  after do
    Issue.reset_column_information
    Issues::Project.reset_column_information
  end

  def connection
    ActiveRecord::Base.connection
  end

  def migrate(direction)
    ActiveRecord::Migration.suppress_messages do
      described_class.new.public_send(direction)
    end
    Issue.reset_column_information
    Issues::Project.reset_column_information
  end

  def insert_issue(project, title, created_at)
    connection.select_value(
      "INSERT INTO issues " \
      "(title, user_id, project_id, created_at, updated_at) VALUES " \
      "(#{connection.quote(title)}, #{project.user_id}, #{project.id}, " \
      "#{connection.quote(created_at)}, #{connection.quote(created_at)}) " \
      "RETURNING id"
    )
  end

  def numbers_by_title
    connection.select_rows(
      "SELECT title, number FROM issues ORDER BY title"
    ).to_h
  end

  def counter(project)
    connection.select_value(
      "SELECT last_issue_number FROM issues_projects " \
      "WHERE id = #{project.id}"
    )
  end

  it "numbers each project's issues from oldest to newest" do
    user = create(:user)
    infra = create(:issues_project, user:)
    web = create(:issues_project, user:)
    migrate(:down)
    insert_issue(infra, "infra-b", Time.utc(2026, 1, 3))
    insert_issue(infra, "infra-a", Time.utc(2026, 1, 2))
    insert_issue(infra, "infra-c", Time.utc(2026, 1, 4))
    insert_issue(web, "web-b", Time.utc(2026, 1, 2))
    insert_issue(web, "web-a", Time.utc(2026, 1, 1))

    migrate(:up)

    expect(numbers_by_title).to eq(
      {
        "infra-a" => 1,
        "infra-b" => 2,
        "infra-c" => 3,
        "web-a" => 1,
        "web-b" => 2
      }
    )
  end

  it "breaks a creation time tie by database id" do
    project = create(:issues_project)
    migrate(:down)
    time = Time.utc(2026, 1, 1)
    older_id = insert_issue(project, "zzz first", time)
    newer_id = insert_issue(project, "aaa second", time)
    # Move the older row behind the newer one in the heap, so that insert
    # order cannot break the tie.
    connection.execute("UPDATE issues SET title = title WHERE id = #{older_id}")

    migrate(:up)

    rows = connection.select_rows(
      "SELECT id, number FROM issues ORDER BY id"
    )
    expect(rows).to eq([[older_id, 1], [newer_id, 2]])
  end

  it "sets each counter to the highest number and leaves empty at 0" do
    user = create(:user)
    infra = create(:issues_project, user:)
    web = create(:issues_project, user:)
    empty = create(:issues_project, user:)
    migrate(:down)
    3.times { |i| insert_issue(infra, "i#{i}", Time.utc(2026, 1, i + 1)) }
    2.times { |i| insert_issue(web, "w#{i}", Time.utc(2026, 1, i + 1)) }

    migrate(:up)

    expect(counter(infra)).to eq(3)
    expect(counter(web)).to eq(2)
    expect(counter(empty)).to eq(0)
  end

  it "requires a number and a unique number in each project" do
    migrate(:down)

    migrate(:up)

    number = connection.columns(:issues).find { it.name == "number" }
    counter = connection.columns(:issues_projects)
      .find { it.name == "last_issue_number" }
    expect(number.null).to be(false)
    expect([counter.null, counter.default]).to eq([false, "0"])
    expect(
      connection.index_exists?(:issues, %i[project_id number], unique: true)
    ).to be(true)
  end

  it "removes the numbers, the counters, and the index on rollback" do
    migrate(:down)

    issue_columns = connection.columns(:issues).map(&:name)
    project_columns = connection.columns(:issues_projects).map(&:name)
    expect(issue_columns).not_to include("number")
    expect(project_columns).not_to include("last_issue_number")
    expect(connection.index_exists?(:issues, %i[project_id number]))
      .to be(false)
  end
end
