# typed: strict

module Galleries
  extend T::Sig

  sig { returns(String) }
  def self.table_name_prefix = "galleries_"

  sig { returns(T::Boolean) }
  def self.use_relative_model_naming? = true
end
