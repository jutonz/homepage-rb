class AddPrUrlToIssues < ActiveRecord::Migration[8.1]
  def change
    add_column(:issues, :pr_url, :string)
  end
end
