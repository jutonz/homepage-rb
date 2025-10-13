module Galleries
  class RecentTagsQuery
    SQL = <<~SQL
      SELECT
        galleries_tags.*,
        MAX(galleries_image_tags.created_at) AS max_tag_created_at
      FROM galleries_tags
      JOIN galleries_image_tags
        ON galleries_image_tags.tag_id = galleries_tags.id
      JOIN (
        SELECT
          galleries_images.id AS id,
          MAX(galleries_image_tags.created_at) AS max_created_at
        FROM galleries_images
        JOIN galleries_image_tags
          ON galleries_image_tags.image_id = galleries_images.id
        JOIN galleries_tags
          ON galleries_image_tags.tag_id = galleries_tags.id
        WHERE galleries_images.gallery_id = ?
          AND galleries_images.id NOT IN (?)
        GROUP BY galleries_images.id
        ORDER BY max_created_at DESC
        LIMIT ?
      ) images
        ON images.id = galleries_image_tags.image_id
      GROUP BY galleries_tags.id
      ORDER BY max_tag_created_at DESC
      ;
    SQL

    def self.call(...) = new(...).call

    def initialize(gallery:, image_limit:, excluded_image_ids: nil)
      @gallery = gallery
      @excluded_image_ids = excluded_image_ids || -1
      @image_limit = image_limit
    end

    def call
      Galleries::Tag.find_by_sql(sanitized_sql)
    end

    private

    attr_reader :gallery
    attr_reader :excluded_image_ids
    attr_reader :image_limit

    def sanitized_sql
      ActiveRecord::Base.sanitize_sql_array([
        SQL,
        gallery.id,
        Array(excluded_image_ids),
        image_limit
      ])
    end
  end
end
