# frozen_string_literal: true

module Recipes
  class FilterService
    
    def self.call(params: {})
      new(params).call
    end
    
    def call
      filter_recipes
    end

    private

    def initialize(params)
      @recipes = Recipe.all
      @rating = params[:rating].to_f
      @ingredients_ids = params[:ingredients_ids]
    end
    
    def filter_recipes
      filter_by_rating
      filter_by_ingredients

      @recipes
    end

    def filter_by_rating
      return unless @rating

      unless @rating.between?(0, 5)
        raise ArgumentError, 'Raiting should be between 0 and 5'
      end

      @recipes = @recipes.with_rating_higher_or_equal_to(@rating)
    end

    def filter_by_ingredients
      return if @ingredients_ids.nil? || @ingredients_ids.empty?

      @recipes = @recipes.with_ingredients(@ingredients_ids)
    end
  end
end
