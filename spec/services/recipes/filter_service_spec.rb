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

      before { recipe2.recipe_ratings << create(:recipe_rating, value: 1)}

      it 'returns recipes with rating higher than or equal to the specified value' do

        expect(described_class.call(params: params)).to eq([recipe1])
      end
    end

    context 'when filtering by ingredients' do
      let(:params) { { ingredients_ids: [recipe_ingredient2.ingredient_id] } }

      it 'returns recipes with the specified ingredients' do
        result = described_class.call(params: params)

        expect(described_class.call(params: params)).to include(recipe1)
        expect(described_class.call(params: params)).not_to include(recipe2)
      end
    end

    context 'when filtering by both rating and ingredients' do
      let(:params) { { rating: 4, ingredients_ids: [recipe_ingredient1.ingredient_id] } }

      before { recipe1.recipe_ratings << create(:recipe_rating, value: 1)}

      it 'returns recipes that satisfy both filters' do
        result = described_class.call(params: params)

        expect(result).to include(recipe2) # because it has rating == 4 and ingredient1
        expect(result).not_to include(recipe1) # because it has ingredient1 but rating is < 4
      end
    end

    context 'when no filters are applied' do
      let(:params) { {} }

      it 'returns all recipes' do
        result = described_class.call(params: params)

        expect(result).to include(recipe1, recipe2)
      end
    end
  end
end
