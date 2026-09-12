# typed: true

module Galleries
  class TagSearch
    include ActiveModel::Model

    sig { returns(Gallery) }
    attr_accessor :gallery

    sig { returns(T.nilable(Galleries::Image)) }
    attr_accessor :image

    sig { returns(T.nilable(String)) }
    attr_accessor :query

    sig { returns(T.nilable(T::Array[Integer])) }
    attr_accessor :excluded_ids

    sig do
      returns(
        T.all(
          ActiveRecord::Relation,
          T::Enumerable[Galleries::Tag]
        )
      )
    end
    def results
      ilike = query&.strip
      return Tag.none if ilike.nil?
      ilike = ActiveRecord::Base.sanitize_sql_like(ilike)

      gallery
        .tags
        .where("galleries_tags.name ILIKE ?", "%#{ilike}%")
        .then { maybe_exclude_image_tags(it) }
        .then { maybe_exclude_ids(it) }
        .order(image_tags_count: :desc, id: :asc)
    end

    private

    sig do
      params(
        scope: T.all(
          ActiveRecord::Relation,
          T::Enumerable[Galleries::Tag]
        )
      ).returns(
        T.all(
          ActiveRecord::Relation,
          T::Enumerable[Galleries::Tag]
        )
      )
    end
    def maybe_exclude_image_tags(scope)
      image = self.image
      if image.present?
        scope.where.not(id: image.tags.select(:id))
      else
        scope
      end
    end

    sig do
      params(
        scope: T.all(
          ActiveRecord::Relation,
          T::Enumerable[Galleries::Tag]
        )
      ).returns(
        T.all(
          ActiveRecord::Relation,
          T::Enumerable[Galleries::Tag]
        )
      )
    end
    def maybe_exclude_ids(scope)
      if excluded_ids.present?
        scope.where.not(id: excluded_ids)
      else
        scope
      end
    end
  end
end
