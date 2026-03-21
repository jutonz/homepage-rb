class AddClassificationToGalleriesTags < ActiveRecord::Migration[8.1]
  def change
    create_enum(
      :galleries_tag_classification,
      %w[none subject]
    )
    add_column(
      :galleries_tags,
      :classification,
      :enum,
      enum_type: :galleries_tag_classification,
      null: false,
      default: "none"
    )
  end
end
