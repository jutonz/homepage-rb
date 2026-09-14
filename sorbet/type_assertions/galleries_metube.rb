# typed: strict
# frozen_string_literal: true

module GalleriesMetubeTypeAssertions
  extend T::Sig

  sig { params(client: Galleries::VideoDownloader::Metube).void }
  def self.assertions(client)
    T.assert_type!(
      client.history,
      T::Hash[String, T::Array[Galleries::VideoDownloader::Metube::Entry]]
    )
  end
end
