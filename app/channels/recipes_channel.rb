# frozen_string_literal: true

class RecipesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "recipe_channel_#{params[:channel_id]}"
  end

  def unsubscribed
    error = 'Action not foreseen ;)'
    ActionCable.server.broadcast(channel(params[:channel_id]), error: error) 
  end

  def filter_recipes(data)
    recipes = Recipes::FilterService.new(params).filter_recipes.as_json

    ActionCable.server.broadcast(channel(params[:channel_id]), recipes: recipes)
  end

  private

  def channel(channel_id)
    "recipes_channel_#{channel_id}"
  end
end
