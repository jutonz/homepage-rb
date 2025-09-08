module Galleries
  class SocialLinksCreator
    AUTO_CREATE_SOCIAL_PREFIXES = {
      "IG:" => "instagram",
      "RD:" => "reddit",
      "TT:" => "tiktok"
    }

    def self.call(tag)
      prefix, platform = AUTO_CREATE_SOCIAL_PREFIXES.find do |prefix, _|
        tag.name.start_with?(prefix)
      end
      return tag unless prefix

      username = tag.name.delete_prefix(prefix)

      # Check if a social link already exists in this gallery
      existing_link = Galleries::SocialMediaLink
        .joins(:tag)
        .where(platform:, username:)
        .where(galleries_tags: {gallery_id: tag.gallery_id})
        .first

      if existing_link
        # Return the existing tag that has this social link
        existing_link.tag
      else
        # Create the social link for this tag
        begin
          tag.social_media_links.find_or_create_by!(platform:, username:)
        rescue ActiveRecord::RecordInvalid => e
          # If this fails due to global uniqueness constraint,
          # it means the social link exists in a different gallery
          # In this case, we'll just skip creating the social link
          # and return the original tag
          Rails.logger.warn("Could not create social link for #{tag.name}: #{e.message}")
        end
        tag
      end
    end
  end
end
