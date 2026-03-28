class AddSystemToGalleriesTagClassification < ActiveRecord::Migration[8.1]
  def change
    add_enum_value(
      :galleries_tag_classification,
      "system",
      if_not_exists: true
    )
  end
end
