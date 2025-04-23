module Galleries
  class SimilarImagesQuery
    def self.call(...) = new(...).call

    def initialize(image:)
      @image = image
    end

    def call
      ids =
        ActiveRecord::Base.sanitize_sql_array([QUERY, image.id, image.id])
          .then { ActiveRecord::Base.connection.execute(it) }
          .map { it["id"] }

      Galleries::Image
        .where(id: ids)
        .order(Arel.sql("array_position(ARRAY[#{ids.join(", ")}], id)"))
    end

    private

    attr_reader :image

    QUERY = <<~SQL
      WITH weighted_tags AS (
        SELECT
          it.image_id,
          it.tag_id,
          1.0 / COUNT(it.image_id) OVER (PARTITION BY it.tag_id) AS weight
        FROM
          galleries_image_tags it
      ),

      similar_images AS (
        SELECT
          images.id,
          SUM(wt1.weight * wt2.weight) AS similarity_score
        FROM
          galleries_images images
        JOIN galleries_image_tags tags
          ON tags.image_id = images.id
        JOIN weighted_tags wt1
          ON wt1.image_id = tags.image_id AND wt1.tag_id = tags.tag_id
        JOIN weighted_tags wt2
          ON wt2.tag_id = tags.tag_id
        WHERE
          wt2.image_id = ?
          AND images.id != ?
        GROUP BY
          images.id
      )

      SELECT
        si.id
      FROM
        similar_images si
      ORDER BY
        si.similarity_score DESC;
    SQL
  end
end
