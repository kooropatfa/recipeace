# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecipeIngredient, type: :model do
  it { should belong_to(:recipe) }
  it { should belong_to(:ingredient) }

  it { should validate_presence_of(:quantity) }

  it 'is valid with valid attributes' do
    recipe_ingredient = build(:recipe_ingredient)
    expect(recipe_ingredient).to be_valid
  end
end
