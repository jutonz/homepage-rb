class CreateGalleriesRemoteVideoDownloads < ActiveRecord::Migration[8.1]
  def change
    create_enum(
      :galleries_remote_video_download_status,
      %w[pending downloading completed failed]
    )

    create_table :galleries_remote_video_downloads do |t|
      t.references(
        :gallery,
        null: false,
        foreign_key: {to_table: :galleries}
      )
      t.references(
        :image,
        null: true,
        foreign_key: {to_table: :galleries_images, on_delete: :nullify}
      )
      t.string(:url, null: false)
      t.enum(
        :status,
        enum_type: :galleries_remote_video_download_status,
        null: false,
        default: "pending"
      )
      t.text(:error_message)
      t.timestamps
    end
  end
end
