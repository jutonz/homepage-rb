# typed: true

# ActiveStorage::Attached::One forwards unknown methods to its
# ActiveStorage::Attachment (`delegate_missing_to :attachment`), and the
# attachment forwards on to its blob the same way. Both hops are
# `method_missing`, so no real method is ever defined and Tapioca has
# nothing to reflect on — the generated activestorage RBI stops at
# `method_missing` itself.
#
# Without this every delegated call fails to resolve, and `open` fails
# worse than that: it misresolves to `Kernel#open` and reports a
# wrong-arity error that points nowhere near the real problem.
#
# Only the methods this app actually reaches through the delegation are
# declared. The signatures mirror the definitions on
# ActiveStorage::Attachment and ActiveStorage::Blob rather than restating
# them, so `content_type` stays nilable here exactly as the blobs table
# allows.
class ActiveStorage::Attached::One
  # Forwarded to ActiveStorage::Attachment.
  sig { returns(T.nilable(::ActiveStorage::Blob)) }
  def blob; end

  sig { params(transformations: T.untyped).returns(::ActiveStorage::Preview) }
  def preview(transformations); end

  sig do
    params(transformations: T.untyped).returns(
      T.any(::ActiveStorage::Variant, ::ActiveStorage::VariantWithRecord)
    )
  end
  def variant(transformations); end

  # Forwarded through the attachment to ActiveStorage::Blob.
  sig { returns(T.nilable(::String)) }
  def content_type; end

  sig { returns(T::Boolean) }
  def previewable?; end

  sig { returns(T::Boolean) }
  def variable?; end

  sig do
    params(
      tmpdir: T.nilable(::String),
      block: T.proc.params(file: ::Tempfile).returns(T.untyped)
    ).returns(T.untyped)
  end
  def open(tmpdir: nil, &block); end
end
