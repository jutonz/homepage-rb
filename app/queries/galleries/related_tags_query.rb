module Galleries
  class RelatedTagsQuery
    Result = Data.define(:tag, :shared_count)

    SQL = <<~SQL
      WITH weighted AS (
        SELECT
          it.image_id,
          it.tag_id,
          1.0 / COUNT(*) OVER (PARTITION BY it.tag_id) AS weight
        FROM galleries_image_tags it
        JOIN galleries_tags t ON t.id = it.tag_id
        WHERE t.gallery_id = ?
      )
      SELECT
        w2.tag_id AS related_tag_id,
        COUNT(DISTINCT w2.image_id) AS shared_count,
        ROUND(SUM(w1.weight * w2.weight), 10) AS score
      FROM weighted w1
      JOIN weighted w2 ON w1.image_id = w2.image_id
      WHERE w1.tag_id = ?
        AND w2.tag_id <> ?
      GROUP BY w2.tag_id
      ORDER BY score DESC, shared_count DESC
      LIMIT 10;
    SQL

    def self.call(...) = new(...).call

    def initialize(tag:)
      @tag = tag
    end

    def call
      raw =
        ActiveRecord::Base
          .sanitize_sql_array([SQL, tag.gallery_id, tag.id, tag.id])
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
