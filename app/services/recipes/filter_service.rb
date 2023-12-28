# frozen_string_literal: true

module Recipes
  class FilterService
    def self.call()
      new(params).call
    end
    
    def call
      filter_recipes
    end

    private

    def initialize(params = {})
      @rating = params[:rating].to_f if params[:rating]
      @ingredients_ids = params[:ingredients_ids]
      @cached_recipes_ids = cached_recipes_ids
      @recipes = Recipe.where(id: @cached_recipes_ids || Recipe.ids)
    end
    
    def filter_recipes
      return @recipes if @cached_recipes_ids # can be an empty array

      cached_recipes_ids do
        filter_by_rating
        filter_by_ingredients

        # Caching only IDs as the recipes can be updated over time.
        # It would be better to cache the whole recipes, but it would require
        # cache key based on the last update of the recipe and its ratings.
        @recipes.ids
      end
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

    def cached_recipes_ids(&block)
      return Rails.cache.read(cache_key) unless block_given?

      return Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
        yield
      end
    end

    def cache_key
      "recipes_filtered_by_rating_#{@rating}_ingredients_#{@ingredients_ids&.sort&.join('_')}"
    end
  end
end
