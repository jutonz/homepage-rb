class AddHiddenToGalleries < ActiveRecord::Migration[7.2]
  def change
    add_column(:galleries, :hidden_at, :datetime)
  end
end
