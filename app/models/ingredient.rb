# frozen_string_literal: true

# frozen_stirng_literal: true

class Ingredient < ApplicationRecord
  has_many :recipe_ingredients
  has_many :recipes, through: :recipe_ingredients, inverse_of: :ingredients

  validates :name, presence: true
end
