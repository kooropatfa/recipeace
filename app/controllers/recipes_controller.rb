# frozen_string_literal: true

class RecipesController < ApplicationController
  def index
    @ingredients = Ingredient.all.order(:name)
    @cache_version = @ingredients.maximum(:updated_at)
  end
end
