# typed: strict

# Sorbet's Struct rewriter creates the reader methods for these results,
# but gives them no signature. The strict upload objects therefore read
# their members as `T.untyped`.
#
# These declarations give the result objects the member types they carry
# at runtime. The nilable image members retain the valid success result,
# which omits the image.
#
# An RBI applies to the static checker only, so nothing here runs.
# `sorbet/type_assertions/plants_upload_results.rb` asserts that these
# declarations still narrow.
module Plants
  class PlantImageUpload
    class Result
      sig { returns(T::Boolean) }
      def saved; end

      sig { returns(T.nilable(Plants::PlantImage)) }
      def plant_image; end
    end
  end

  class InboxImageUpload
    class Result
      sig { returns(T::Boolean) }
      def saved; end

      sig { returns(T.nilable(Plants::InboxImage)) }
      def inbox_image; end
    end
  end
end
