require "rails_helper"

RSpec.describe Galleries::Images::TagSearch do
  describe "#results" do
    it "returns nothing if the query is nil" do
      search = build(
        :galleries_images_tag_search,
        query: nil
      )

      expect(search.results).to be_blank
    end

    it "returns tags matching the name" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      matching_tag = create(:galleries_tag, gallery:, name: "hello")
      _not_matching_tag = create(:galleries_tag, gallery:, name: "goodbye")
      search = build(
        :galleries_images_tag_search,
        gallery:,
        image:,
        query: "hello"
      )

      result = search.results.pluck(:id)

      expect(result).to eql([matching_tag.id])
    end

    it "supports partial matches" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      tag = create(:galleries_tag, gallery:, name: "hello")
      search = build(
        :galleries_images_tag_search,
        gallery:,
        image:,
        query: "hel"
      )

      result = search.results.pluck(:id)

      expect(result).to eql([tag.id])
    end

    it "ignores trailing whitespace in the query" do
      gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      tag = create(:galleries_tag, gallery:, name: "hello")
      search = build(
        :galleries_images_tag_search,
        gallery:,
        image:,
        query: "hello "
      )

      result = search.results.pluck(:id)

      expect(result).to eql([tag.id])
    end

    it "doesn't return tags belonging to other galleries" do
      search = build(:galleries_images_tag_search, query: "hello")
      gallery = search.gallery
      tag = create(:galleries_tag, gallery:, name: "hello")
      _other_tag = create(:galleries_tag, name: "hello")

      result = search.results.pluck(:id)

      expect(result).to eql([tag.id])
    end

    it "excludes tags already applied to the image" do
      search = build(:galleries_images_tag_search, query: "hello")
      gallery = search.gallery
      image = search.image
      tag = create(:galleries_tag, gallery:, name: "hello")
      image.add_tag(tag)

      result = search.results.pluck(:id)

      expect(result).to be_blank
    end

    it "orders tags by name" do
      search = build(:galleries_images_tag_search, query: "Tag")
      gallery = search.gallery
      tag_b = create(:galleries_tag, gallery:, name: "Tag B")
      tag_a = create(:galleries_tag, gallery:, name: "Tag A")

      result = search.results.pluck(:name)

      expect(result).to eql([tag_a.name, tag_b.name])
    end
  end
end
