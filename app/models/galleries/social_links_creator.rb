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
      link = tag.social_media_links.find_or_create_by!(platform:, username:)
      classify_from_link(tag, link)
    end

    def self.classify_from_link(tag, link)
      tag.update!(classification: "subject") if link.instagram?
    end
  end
end
