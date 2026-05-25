module Galleries
  class RelatedTagsQuery
    Result = Data.define(:tag, :shared_count)

    SQL = <<~SQL
      SELECT
        it2.tag_id AS related_tag_id,
        COUNT(DISTINCT it2.image_id) AS shared_count
      FROM galleries_image_tags it1
      JOIN galleries_image_tags it2 ON it1.image_id = it2.image_id
      JOIN galleries_tags t2 ON t2.id = it2.tag_id
      WHERE it1.tag_id = ?
        AND it2.tag_id <> ?
        AND t2.gallery_id = ?
      GROUP BY it2.tag_id
      ORDER BY shared_count DESC
      LIMIT 10;
    SQL

    def self.call(...) = new(...).call

    def initialize(tag:)
      @tag = tag
    end

    def call
      raw =
        ActiveRecord::Base
          .sanitize_sql_array([SQL, tag.id, tag.id, tag.gallery_id])
          .then { ActiveRecord::Base.connection.execute(it) }

      tag_ids = raw.map { it["related_tag_id"] }
      tags =
        Galleries::Tag.includes(:gallery).where(id: tag_ids).index_by(&:id)

      raw.map do |row|
        Result.new(
          tag: tags[row["related_tag_id"]],
          shared_count: row["shared_count"].to_i
        )
      end
    end

    private

    attr_reader :tag
  end
end
