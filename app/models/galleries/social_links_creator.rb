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
      return unless prefix

      username = tag.name.delete_prefix(prefix)
      tag.social_media_links.find_or_create_by!(platform:, username:)
    end
  end
end
