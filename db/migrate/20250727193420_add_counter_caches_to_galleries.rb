class AddCounterCachesToGalleries < ActiveRecord::Migration[8.0]
  def change
    add_column(
      :galleries,
      :images_count,
      :integer,
      default: 0,
      null: false
    )
    add_column(
      :galleries,
      :tags_count,
      :integer,
      default: 0,
      null: false
    )

    reversible do |dir|
      dir.up do
        Gallery.pluck(:id).each do |id|
          Gallery.reset_counters(id, :images)
          Gallery.reset_counters(id, :tags)
        end
      end
    end
  end
end
