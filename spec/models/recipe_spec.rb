# frozen_string_literal: true

# spec/models/recipe_spec.rb
require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe 'associations' do
    it { should have_many(:recipe_ratings).dependent(:destroy) }
    it { should have_many(:recipe_ingredients).dependent(:destroy) }
    it { should have_many(:ingredients).through(:recipe_ingredients) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:instructions) }
  end

  let!(:recipe1) { create(:recipe, :with_3_ratings) } # average rating for these recipes is 4
  let!(:recipe2) { create(:recipe, :with_3_ratings) }
  let!(:recipe3) { create(:recipe, :with_3_ratings) }

  describe 'scopes' do
    context 'ratings' do

      describe '.with_rating_higher_than' do
        context 'when given value is not a number' do
          it 'raises ArgumentError' do
            expect { described_class.with_rating_higher_or_equal_to('brr') }.to raise_error(ArgumentError)
          end
        end

        context 'when given value is a number' do
          it 'returns recipes with average rating higher or equal to the given value' do
            expect(described_class.with_rating_higher_or_equal_to(4)).to match_array([recipe1, recipe2, recipe3])
          end

          it 'does not return recipes with average rating lower than the given value' do
            expect(described_class.with_rating_higher_or_equal_to(4.1)).to eq([])
          end

          it 'returns recipes ordered by average rating descending' do
            recipe1.recipe_ratings.create(value: 2)
            recipe2.recipe_ratings.create(value: 5)

            expect(described_class.with_rating_higher_or_equal_to(3)).to eq([recipe2, recipe3, recipe1])
          end
        end
      end
    end

    context 'ingredients' do
      describe '.with_ingredients' do
        let(:ingredient1) { create(:ingredient) }
        let(:ingredient2) { create(:ingredient) }
        let(:ingredient3) { create(:ingredient) }

        let!(:recipe1_ingredient1) { create(:recipe_ingredient, recipe: recipe1, ingredient: ingredient1) }
        let!(:recipe1_ingredient2) { create(:recipe_ingredient, recipe: recipe1, ingredient: ingredient2) }

        let!(:recipe2_ingredient2) { create(:recipe_ingredient, recipe: recipe2, ingredient: ingredient2) }

        let!(:recipe3_ingredient1) { create(:recipe_ingredient, recipe: recipe3, ingredient: ingredient1) }
        let!(:recipe3_ingredient2) { create(:recipe_ingredient, recipe: recipe3, ingredient: ingredient2) }
        let!(:recipe3_ingredient3) { create(:recipe_ingredient, recipe: recipe3, ingredient: ingredient3) }
        
        it 'returns recipes with specified ingredient ids' do
          recipe_ingredients_ids = [ingredient1.id, ingredient2.id]
          result = described_class.with_ingredients(recipe_ingredients_ids)

          expect(result.pluck(:id)).to include(recipe1.id, recipe3.id)
          expect(result).not_to include(recipe2)
        end
      end
    end
  end
end
