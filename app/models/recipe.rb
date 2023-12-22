class Recipe < ApplicationRecord
  has_many :recipe_ratings, dependent: :destroy
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  validates :title, presence: true
  validates :instructions, presence: true

  scope :with_rating_higher_or_equal_to, ->(rating) do
    raise ArgumentError unless rating.is_a?(Numeric)

    joins(:recipe_ratings)
      .group('recipes.id')
      .having("AVG(recipe_ratings.value) >= ?", rating)
  end

  scope :with_ingredients, ->(ids) do
    joins(:recipe_ingredients)
      .where(recipe_ingredients: { ingredient_id: ids })
  end
end
