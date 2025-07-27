module Galleries
  class SocialLinksCreator
    AUTO_CREATE_SOCIAL_PREFIXES = {
      "IG:" => "instagram",
      "RD:" => "reddit",
      "TT:" => "tiktok"
    }

    def self.call(tag)
      AUTO_CREATE_SOCIAL_PREFIXES.each do |(prefix, platform)|
        if tag.name.start_with?(prefix)
          username = tag.name.split(prefix).last
          tag.social_media_links.find_or_create_by!(platform:, username:)
        end
      end
    end
  end
end
