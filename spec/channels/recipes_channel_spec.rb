# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecipesChannel, type: :channel do
  let(:channel_id) { 'unique_channel_id' }

  it 'subscribes to a channel' do
    subscribe(channel_id: channel_id)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("recipes_channel_#{channel_id}")
  end

  it 'broadcasts an error on unsubscribed', skip: 'Debugging in progress...' do
    subscribe(channel_id: channel_id)
    error = 'Action not foreseen ;)'
  
    expect(ActionCable.server).to receive(:broadcast)
      .with("recipes_channel_#{channel_id}", hash_including(error: error))
  
    unsubscribe
  end

  it 'broadcasts filtered recipes on filter_recipes' do
    recipes = [create_list(:recipe, 2)]
    allow_any_instance_of(described_class).to receive(:sort_and_serialize).and_return(recipes)

    subscribe(channel_id: channel_id)

    expect(ActionCable.server).to receive(:broadcast)
      .with("recipes_channel_#{channel_id}", hash_including(recipes: recipes))

    perform(:filter_recipes, { 'min_rating' => '4.0', 'channel_id' => channel_id })
  end
end
