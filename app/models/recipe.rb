# frozen_string_literal: true

class Recipe < ApplicationRecord
  has_many :recipe_ratings, dependent: :destroy
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  validates :title, presence: true
  validates :instructions, presence: true

  scope :with_rating_higher_or_equal_to, lambda { |rating|
    raise ArgumentError unless rating.is_a?(Numeric)

    joins(:recipe_ratings)
      .group('recipes.id')
      .having('AVG(recipe_ratings.value) >= ?', rating)
      .order('AVG(recipe_ratings.value) DESC')
  }

  scope :with_ingredients, lambda { |ids|
    joins(:recipe_ingredients)
      .where(recipe_ingredients: { ingredient_id: ids })
      .group('recipes.id')
      .having('COUNT(DISTINCT recipe_ingredients.ingredient_id) >= ?', ids.length)
  }

  def rating
    recipe_ratings.average(:value).to_f.round(1)
  end
end
