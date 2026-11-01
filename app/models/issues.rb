# typed: strict

module Issues
  sig { returns(String) }
  def self.table_name_prefix = "issues_"

  sig { returns(T::Boolean) }
  def self.use_relative_model_naming? = true
end
