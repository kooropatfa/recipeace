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
      @rating = params[:rating].to_f
      @ingredients_ids = params[:ingredients_ids]
      @cached_recipes = cached_recipes
      @recipes = @cached_recipes || Recipe.all
    end
    
    def filter_recipes
      return @cached_recipes if @cached_recipes # can be an empty array

      cached_recipes do
        filter_by_rating
        filter_by_ingredients

        @recipes.pluck(:id)
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

    def cached_recipes(&block)
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
