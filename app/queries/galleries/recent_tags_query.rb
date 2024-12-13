module Galleries
  class RecentTagsQuery
    def self.call(...) = new(...).call

    def initialize(gallery:, excluded_image_ids:, image_limit:)
      @gallery = gallery
      @excluded_image_ids = excluded_image_ids
      @image_limit = image_limit
    end

    def call
      Galleries::Tag.find_by_sql(sanitized_sql).then do |result|
        if excluded_image_ids.present?
          Galleries::Tag
            .joins(:images)
            .where.not(galleries_images: {id: excluded_image_ids})
            .where(id: result.pluck(:id))
            .distinct
        else
          result
        end
      end
    end

    private

    attr_reader :gallery
    attr_reader :excluded_image_ids
    attr_reader :image_limit

    SQL = <<~SQL
      SELECT DISTINCT
        galleries_tags.*,
        galleries_tags.name
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
        GROUP BY galleries_images.id
        ORDER BY max_created_at DESC
        LIMIT ?
      ) images
        ON images.id = galleries_image_tags.image_id
      ORDER BY galleries_tags.name
      ;
    SQL

    def sanitized_sql
      ActiveRecord::Base.sanitize_sql_array([
        SQL,
        gallery.id,
        image_limit
      ])
    end
  end
end
