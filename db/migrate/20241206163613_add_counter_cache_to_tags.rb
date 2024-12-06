class AddCounterCacheToTags < ActiveRecord::Migration[7.2]
  def change
    add_column(
      :galleries_tags,
      :image_tags_count,
      :integer,
      default: 0,
      null: false
    )

    reversible do |dir|
      dir.up do
        Galleries::Tag.pluck(:id).each do |id|
          Galleries::Tag.reset_counters(id, :image_tags)
        end
      end
    end
  end
end
