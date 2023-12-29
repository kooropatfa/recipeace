# frozen_string_literal: true

class RecipesChannel < ApplicationCable::Channel
  def subscribed
    stream_from channel
  end

  def unsubscribe
    ActionCable.server.broadcast(channel, 'Action not foreseen ;)')
  end

  def filter_recipes(data)
    recipes_ids = Recipes::FilterService.call(data.with_indifferent_access)

    recipes = sort_and_serialize(recipes_ids)    

    ActionCable.server.broadcast(channel, { recipes: recipes })
  end

  private

  def channel
    "recipes_channel_#{params[:channel_id]}"
  end

  # I'm leaving this method here for now,
  # but it should be moved to a service or a decorator.
  def sort_and_serialize(recipes_ids)
    Recipe.includes(:ingredients)
      .where(id: recipes_ids)
      .order(:title).map do |recipe|
        recipe.serializable_hash(methods: :rating,
                                include: {
                                  recipe_ingredients: {
                                    include: :ingredient 
                                  }
                                })
    end
  end
end
