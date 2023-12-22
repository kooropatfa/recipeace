# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecipeRating, type: :model do
  it { should belong_to(:recipe) }

  it { should validate_presence_of(:value) }
  it { should validate_inclusion_of(:value).in_array((0..5).to_a) }

  it 'is valid with valid attributes' do
    rating = build(:recipe_rating)
    expect(rating).to be_valid
  end
end
