# typed: strict

module Plants
  sig { returns(String) }
  def self.table_name_prefix
    "plants_"
  end
end
