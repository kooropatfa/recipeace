# frozen_string_literal: true

# spec/models/recipe_spec.rb
require 'rails_helper'

RSpec.describe Recipe, type: :model do
  let(:recipe) { create(:recipe) }

  describe 'associations' do
    it { should have_many(:recipe_ratings).dependent(:destroy) }
    it { should have_many(:recipe_ingredients).dependent(:destroy) }
    it { should have_many(:ingredients).through(:recipe_ingredients) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:instructions) }
  end

  describe 'scopes' do
    describe '.with_raiting_higher_than' do
      context 'when given value is not a number' do
        it 'raises ArgumentError' do
          expect { described_class.with_raiting_higher_or_equal_to('brr') }.to raise_error(ArgumentError)
        end
      end

      context 'when given value is a number' do
        let!(:recipe) { create(:recipe, :with_3_ratings) }

        it 'returns recipes with average rating higher or equal to the given value' do
          expect(described_class.with_raiting_higher_or_equal_to(4)).to include(recipe)
        end

        it 'does not return recipes with average rating lower than the given value' do
          expect(described_class.with_raiting_higher_or_equal_to(4.1)).not_to include(recipe)
        end
      end
    end

    describe '.with_ingredients' do
      let(:recipe_ingredient1) { create(:recipe_ingredient) }
      let(:recipe_ingredient2) { create(:recipe_ingredient) }
      let!(:recipe1) { create(:recipe, recipe_ingredients: [recipe_ingredient1, recipe_ingredient2]) }
      let!(:recipe2) { create(:recipe, recipe_ingredients: [recipe_ingredient1]) }

      it 'returns recipes with specified ingredient ids' do
        result = described_class.with_ingredients([recipe_ingredient2.ingredient_id])

        expect(result).to include(recipe1)
        expect(result).not_to include(recipe2)
      end
    end
  end
end
