SELECT DISTINCT galleries_images.*
FROM galleries_images
INNER JOIN galleries_image_tags
    ON galleries_image_tags.image_id = galleries_images.id
INNER JOIN galleries_tags tags
    ON tags.id = galleries_image_tags.tag_id
WHERE tags.id = 1
  AND galleries_images.id != 14
