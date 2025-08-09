# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Recipe Units
recipe_units = [
  # Volume units
  {name: "cup", abbreviation: "c", unit_type: "volume"},
  {name: "tablespoon", abbreviation: "tbsp", unit_type: "volume"},
  {name: "teaspoon", abbreviation: "tsp", unit_type: "volume"},
  {name: "fluid ounce", abbreviation: "fl oz", unit_type: "volume"},
  {name: "pint", abbreviation: "pt", unit_type: "volume"},
  {name: "quart", abbreviation: "qt", unit_type: "volume"},
  {name: "gallon", abbreviation: "gal", unit_type: "volume"},
  {name: "milliliter", abbreviation: "ml", unit_type: "volume"},
  {name: "liter", abbreviation: "l", unit_type: "volume"},

  # Weight units
  {name: "ounce", abbreviation: "oz", unit_type: "weight"},
  {name: "pound", abbreviation: "lb", unit_type: "weight"},
  {name: "gram", abbreviation: "g", unit_type: "weight"},
  {name: "kilogram", abbreviation: "kg", unit_type: "weight"},

  # Count units
  {name: "piece", abbreviation: "pc", unit_type: "count"},
  {name: "item", abbreviation: "item", unit_type: "count"},
  {name: "clove", abbreviation: "clove", unit_type: "count"},
  {name: "head", abbreviation: "head", unit_type: "count"},
  {name: "bunch", abbreviation: "bunch", unit_type: "count"},
  {name: "slice", abbreviation: "slice", unit_type: "count"},
  {name: "can", abbreviation: "can", unit_type: "count"}
]

recipe_units.each do |unit_attrs|
  Recipes::Unit.find_or_create_by!(name: unit_attrs[:name]) do |unit|
    unit.abbreviation = unit_attrs[:abbreviation]
    unit.unit_type = unit_attrs[:unit_type]
  end
end
