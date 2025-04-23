-- SELECT
--   DISTINCT ON (galleries_images.id)
--   galleries_images.id AS image_id,
--   tags.id AS tag_id,
--   tags.image_tags_count,
--   CASE
--     WHEN tags.image_tags_count = 0 THEN 1.0
--     ELSE 1.0 / tags.image_tags_count
--   END as weight
-- FROM galleries_images
-- INNER JOIN galleries_image_tags
--     ON galleries_image_tags.image_id = galleries_images.id
-- INNER JOIN galleries_tags tags
--     ON tags.id = galleries_image_tags.tag_id
-- WHERE tags.id IN (125)
--   AND galleries_images.id != 10869;

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
    si.id,
    SUM(wt1.weight * wt2.weight) AS similarity_score
  FROM
    galleries_images si
  JOIN galleries_image_tags it1 ON it1.image_id = si.id
  JOIN weighted_tags wt1 ON wt1.image_id = it1.image_id AND wt1.tag_id = it1.tag_id
  JOIN weighted_tags wt2 ON wt2.tag_id = it1.tag_id
  WHERE
    wt2.image_id = 10869
    AND si.id != 10869
  GROUP BY
    si.id
)

SELECT
  si.id
FROM
  similar_images si
ORDER BY
  si.similarity_score DESC
LIMIT 20;

-- WITH weighted_tags AS (
--   SELECT
--     it.image_id,
--     it.tag_id,
--     1.0 / COUNT(it.image_id) OVER (PARTITION BY it.tag_id) AS weight
--   FROM
--     galleries_image_tags it
-- ),
--
-- similar_images AS (
--   SELECT
--     si.id,
--     SUM(wt1.weight * wt2.weight) AS similarity_score
--   FROM
--     images si
--   JOIN image_tags it1 ON it1.image_id = si.id
--   JOIN weighted_tags wt1 ON wt1.image_id = it1.image_id AND wt1.tag_id = it1.tag_id
--   JOIN weighted_tags wt2 ON wt2.tag_id = it1.tag_id
--   WHERE
--     wt2.image_id = :image_id
--     AND si.id != :image_id
--   GROUP BY
--     si.id
-- )
--
-- SELECT
--   si.id
-- FROM
--   similar_images si
-- ORDER BY
--   si.similarity_score DESC;
