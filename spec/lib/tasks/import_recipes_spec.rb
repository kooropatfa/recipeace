# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'mealdb:import_recipes_and_ingredients' do
  before do
    Rake.application.rake_require('lib/tasks/mealdb/import_recipes_and_ingredients', [Rails.root.to_s])
    Rake::Task.define_task(:environment)
  end

  describe 'mealdb:import_recipes_and_ingredients' do
    let(:task) { Rake::Task['mealdb:import_recipes_and_ingredients'] }

    before do
      allow(HTTParty).to receive(:get).and_return(double(code: 200, body: { meals: [sample_recipe_data] }.to_json))
    end

    context 'when the API request is successful' do
      context 'when the data does not exist' do
        it 'imports recipes and ingredients' do
          expect { task.invoke }.to change { Recipe.count }.by(1)
            .and change { Ingredient.count }.by(2)
            .and change { RecipeIngredient.count }.by(2)
            .and change { RecipeRating.count }.by(5)
        end
      end

      context 'when records already exists' do
        it 'does not import recipes that already exist' do
          Recipe.create(mealdb_id: 123, title: 'Kiwi donuts', instructions: 'Prepare.')

          expect { task.invoke }.not_to change { Recipe.count }
        end

        it 'does not import ingredients that already exist' do
          Ingredient.create(name: 'Donuts')
          Ingredient.create(name: 'Kiwi')

          expect { task.invoke }.to change { Ingredient.count }.by(0)
        end
      end
    end
  
    context 'when the API request fails' do
      before do
        allow(HTTParty).to receive(:get).and_return(double(code: 401, body: 'No recipes for you!'))
      end

      it 'handles the failure gracefully' do
        expect { task.invoke }.not_to change { Recipe.count }
      end
    end
  end

  def sample_recipe_data
    {
      'idMeal' => 123,
      'strMeal' => 'Kiwi Donuts',
      'strInstructions' => 'Stuff donuts with kiwi',
      'strIngredient1' => 'Donuts',
      'strMeasure1' => 'many',
      'strIngredient2' => 'Kiwi',
      'strMeasure2' => 'some',
    }
  end
end
