# frozen_string_literal: true

class RecipeIngredient < ApplicationRecord
  belongs_to :recipe, inverse_of: :recipe_ingredients, optional: false
  belongs_to :ingredient, inverse_of: :recipe_ingredients, optional: false

  validates :quantity, presence: true
end
