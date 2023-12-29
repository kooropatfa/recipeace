# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recipes::FilterService do
  describe '.call' do
    let(:recipe_ingredient1) { create(:recipe_ingredient) }
    let(:recipe_ingredient2) { create(:recipe_ingredient) }
    let!(:recipe1) do
      create(:recipe, :with_3_ratings,
             recipe_ingredients: [recipe_ingredient1, recipe_ingredient2])
    end
    let!(:recipe2) do
      create(:recipe, :with_3_ratings,
             recipe_ingredients: [recipe_ingredient1])
    end

    context 'when filtering by rating' do
      let(:params) { { rating: 4 } }

      before { recipe2.recipe_ratings << create(:recipe_rating, value: 1) }

      it 'returns recipes with rating higher than or equal to the specified value' do
        expect(described_class.call(params)).to eq([recipe1.id])
      end

      context 'when rating is a number that is not between 0 and 5' do
        let(:params) { { rating: 6 } }

        it 'raises ArgumentError' do
          expect { described_class.call(params) }.to raise_error(ArgumentError)
        end
      end
    end

    context 'when filtering by ingredients' do
      let(:params) { { ingredients_ids: [recipe_ingredient2.ingredient_id] } }

      it 'returns recipes with the specified ingredients' do
        result = described_class.call(params)

        expect(result).to include(recipe1.id)
        expect(result).not_to include(recipe2.id)
      end
    end

    context 'when filtering by both rating and ingredients' do
      let(:params) { { rating: 4, ingredients_ids: [recipe_ingredient1.ingredient_id] } }

      before { recipe1.recipe_ratings << create(:recipe_rating, value: 1) }

      it 'returns recipes that satisfy both filters' do
        result = described_class.call(params)

        expect(result).to include(recipe2.id)
        expect(result).not_to include(recipe1.id)
      end
    end

    context 'when no filters are applied' do
      let(:params) { {} }

      it 'returns all recipes' do
        result = described_class.call(params)

        expect(result).to include(recipe1.id, recipe2.id)
      end
    end

    context 'when there are recipies matching filter query stored in cache' do
      let(:cached_params) { { rating: 4, ingredients_ids: [recipe_ingredient1.ingredient_id] } }

      it 'returns cached recipes from cache' do
        # Read from cache but it's empty so it will be written
        expect(Rails.cache).to receive(:read).and_call_original
        expect(Rails.cache).to receive(:fetch).twice.and_call_original
        described_class.call(cached_params)

        # And as the value is present now just read from cache
        expect(Rails.cache).to receive(:read).and_call_original
        result = described_class.call(params: cached_params)

        expect(result).to include(recipe2.id)
      end
    end
  end
end
