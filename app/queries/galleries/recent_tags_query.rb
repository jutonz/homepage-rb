module Galleries
  class RecentTagsQuery
    Result = Data.define(:tag, :most_recent_image_id)

    SQL = <<~SQL
      WITH recent_images AS (
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
      ),
      tag_max_times AS (
        SELECT
          galleries_tags.id AS tag_id,
          MAX(galleries_image_tags.created_at) AS max_tag_created_at
        FROM galleries_tags
        JOIN galleries_image_tags
          ON galleries_image_tags.tag_id = galleries_tags.id
        JOIN recent_images
          ON recent_images.id = galleries_image_tags.image_id
        GROUP BY galleries_tags.id
      )
      SELECT
        galleries_tags.*,
        tmt.max_tag_created_at,
        (
          SELECT git.image_id
          FROM galleries_image_tags git
          JOIN recent_images ri ON ri.id = git.image_id
          WHERE git.tag_id = galleries_tags.id
            AND git.created_at = tmt.max_tag_created_at
          LIMIT 1
        ) AS most_recent_image_id
      FROM galleries_tags
      JOIN tag_max_times tmt ON tmt.tag_id = galleries_tags.id
      ORDER BY tmt.max_tag_created_at DESC
      ;
    SQL

    def self.call(...) = new(...).call

    def initialize(gallery:, image_limit:, excluded_image_ids: nil)
      @gallery = gallery
      @excluded_image_ids = excluded_image_ids || -1
      @image_limit = image_limit
    end

    def call
      raw_results = ActiveRecord::Base.connection.execute(sanitized_sql)
      tag_ids = raw_results.map { |row| row["id"] }
      image_id_map = raw_results.each_with_object({}) do |row, hash|
        hash[row["id"]] = row["most_recent_image_id"]
      end

      tags = Galleries::Tag
        .where(id: tag_ids)
        .index_by(&:id)

      tag_ids.map do |tag_id|
        Result.new(
          tag: tags[tag_id],
          most_recent_image_id: image_id_map[tag_id]
        )
      end
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
