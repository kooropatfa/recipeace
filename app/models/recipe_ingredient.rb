# frozen_string_literal: true

class RecipeIngredient < ApplicationRecord
  belongs_to :recipe, optional: false
  belongs_to :ingredient, optional: false

  validates :quantity, presence: true
end
