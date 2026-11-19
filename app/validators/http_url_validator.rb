# typed: strict

class HttpUrlValidator < ActiveModel::EachValidator
  sig do
    params(
      record: ActiveModel::Validations,
      attribute: Symbol,
      value: T.nilable(String)
    ).void
  end
  def validate_each(record, attribute, value)
    return if value.nil? || http_url?(value)

    record.errors.add(attribute, "is not a valid http(s) URL")
  end

  private

  sig { params(url: String).returns(T::Boolean) }
  def http_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
