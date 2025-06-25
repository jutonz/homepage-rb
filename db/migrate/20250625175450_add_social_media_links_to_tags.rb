class AddSocialMediaLinksToTags < ActiveRecord::Migration[8.0]
  def change
    create_table(:galleries_social_media_links) do |t|
      t.references(:tag, null: false, foreign_key: {to_table: :galleries_tags})
      t.string(:platform, null: false)
      t.string(:username, null: false)
      t.timestamps
    end

    add_index(
      :galleries_social_media_links,
      [:platform, :username],
      unique: true
    )
  end
end
