# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecipesChannel, type: :channel do
  let(:channel_id) { 'unique_channel_id' }

  it 'subscribes to a channel' do
    subscribe(channel_id: channel_id)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("recipe_channel_#{channel_id}")
  end

  it 'broadcasts an error on unsubscribed' do
    subscribe(channel_id: channel_id)
    error = 'Action not foreseen ;)'

    expect(ActionCable.server).to receive(:broadcast)
      .with("recipes_channel_#{channel_id}", error: error)

    unsubscribe
  end

  it 'broadcasts filtered recipes on filter_recipes' do
    recipes = [Recipe.new(title: 'Recipe 1'), Recipe.new(title: 'Recipe 2')]
    allow(Recipes::FilterService).to receive_message_chain(:new, :filter_recipes).and_return(recipes)

    subscribe(channel_id: channel_id)

    expect(ActionCable.server).to receive(:broadcast)
      .with("recipes_channel_#{channel_id}", recipes: recipes.as_json)

    perform(:filter_recipes, { 'min_rating' => '4.0', 'channel_id' => channel_id })
  end
end
