# typed: true

# Kaminari defines `page` on each model at runtime, so no gem RBI
# declares it. This declaration gives it the return type it has at
# runtime.
#
# An RBI applies to the static checker only, so nothing here runs.
# `sorbet/type_assertions/kaminari_page.rb` asserts that this
# declaration still narrows.
class Galleries::Image::PrivateAssociationRelation
  sig do
    params(num: T.untyped)
      .returns(Galleries::Image::PrivateAssociationRelation)
  end
  def page(num = nil); end
end
