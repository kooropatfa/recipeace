# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  it { should have_many(:recipe_ingredients) }
  it { should have_many(:recipes).through(:recipe_ingredients) }

  it { should validate_presence_of(:name) }

  it 'is valid with valid attributes' do
    ingredient = build(:ingredient)
    expect(ingredient).to be_valid
  end
end

