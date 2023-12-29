# frozen_string_literal: true

namespace :mealdb do
  desc 'Import recipes and ingredients from TheMealDB'
  task import_recipes_and_ingredients: :environment do
    mealdb_api_url = 'https://www.themealdb.com/api/json/v1/1/random.php'

    25.times do
      response = HTTParty.get(mealdb_api_url)

      if response.code == 200
        recipe_data = JSON.parse(response.body)['meals'][0]

        import_recipe_with_ingredients(recipe_data)
      else
        puts "Failed to fetch data from TheMealDB. HTTP Status: #{response.code}"
      end
    end

    puts 'Import completed successfully!'
  end

  def import_recipe_with_ingredients(recipe_data)
    recipe = Recipe.find_or_initialize_by(mealdb_id: recipe_data['idMeal']&.to_i)

    return if recipe.persisted?

    recipe.title = recipe_data['strMeal']
    recipe.instructions = recipe_data['strInstructions']

    # Import ingredients for the recipe
    ingredients = []

    ActiveRecord::Base.transaction do
      (1..20).each do |i|
        ingredient_name = recipe_data["strIngredient#{i}"]

        break if ingredient_name.blank?

        quantity = recipe_data["strMeasure#{i}"]
        ingredient = Ingredient.find_or_create_by(name: ingredient_name)
        recipe_ingredient = RecipeIngredient.new(ingredient: ingredient, recipe: recipe, quantity: quantity)
        ingredients << recipe_ingredient
      end

      recipe.recipe_ingredients = ingredients

      # Ratings are not implemented yet so we'll just generate random ones

      # TODO: update spec
      5.times do
        recipe.recipe_ratings.build(value: rand(1..5))
      end

      p "Imported #{recipe.title}" if recipe.save
    end
  end
end
