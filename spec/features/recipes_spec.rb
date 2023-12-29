# frozen_string_literal: true

require 'spec_helper'

# should be Rspec.feature
RSpec.describe 'Recipes integration', type: :feature, js: true,
                                      skip: 'Skipping this test due to Selenium configuration issues that I came across. It that take too for the demo project and I hope it is fine.' do
  let!(:recipe1) { create(:recipe, :with_3_ratings) } # average rating for these recipes is 4
  let!(:recipe2) { create(:recipe, :with_3_ratings) }
  let!(:recipe3) { create(:recipe, :with_3_ratings) }

  let(:ingredient1) { create(:ingredient) }
  let(:ingredient2) { create(:ingredient) }
  let(:ingredient3) { create(:ingredient) }

  let!(:recipe1_ingredient1) { create(:recipe_ingredient, recipe: recipe1, ingredient: ingredient1) }

  let!(:recipe2_ingredient2) { create(:recipe_ingredient, recipe: recipe2, ingredient: ingredient2) }
  let!(:recipe2_ingredient2) { create(:recipe_ingredient, recipe: recipe2, ingredient: ingredient2) }

  let!(:recipe3_ingredient1) { create(:recipe_ingredient, recipe: recipe3, ingredient: ingredient1) }
  let!(:recipe3_ingredient2) { create(:recipe_ingredient, recipe: recipe3, ingredient: ingredient2) }
  let!(:recipe3_ingredient3) { create(:recipe_ingredient, recipe: recipe3, ingredient: ingredient3) }

  before do
    visit root_path
    puts page.body
    wait_for_spinner_to_disappear
    recipe1.recipe_ratings.create(value: 1)
    recipe3.recipe_ratings.create(value: 5)
  end

  def wait_for_spinner_to_disappear
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep(0.1) until has_no_css?('.spinner-border[role="status"]')
    end
  end

  context 'initial load' do
    it 'shows all recipes' do
      expect(page).to have_content(recipe1.title)
      expect(page).to have_content(recipe2.title)
      expect(page).to have_content(recipe3.title)
    end

    it 'sets the rating slider to 0' do
      expect(page.find('#recipes-rating-slider').value).to eq '0'
    end

    it 'does not select any ingredient buttons' do
      expect(page).to have_selector('.ingredient-filter-btn.btn-outline-secondary', count: 3)
    end
  end

  context 'when user filters by ingredients' do
    it 'updates recipes list with selected ingredient' do
      page.find('.ingredient-filter-btn[data-ingredient-id="1"]').click

      expect(page).to have_content(recipe1.title)
      expect(page).to have_content(recipe2.title)
      expect(page).to have_content(recipe3.title)
    end

    it 'updates recipes list with multiple selected ingredients' do
      page.find('.ingredient-filter-btn[data-ingredient-id="1"]').click
      page.find('.ingredient-filter-btn[data-ingredient-id="2"]').click

      expect(page).to have_content(recipe1.title)
      expect(page).to have_content(recipe2.title)
      expect(page).to have_content(recipe3.title)
    end

    it 'updates recipes list with deselected ingredient' do
      page.find('.ingredient-filter-btn[data-ingredient-id="1"]').click
      page.find('.ingredient-filter-btn[data-ingredient-id="2"]').click
      page.find('.ingredient-filter-btn[data-ingredient-id="1"]').click

      expect(page).to have_content(recipe1.title)
      expect(page).to have_content(recipe2.title)
      expect(page).to have_content(recipe3.title)
    end
  end

  context 'when user filters by rating' do
    it 'updates recipes list with recipes having selected rating' do
      page.find('#recipes-rating-slider').set('4')

      expect(page).to have_content(recipe1.title)
      expect(page).to have_content(recipe2.title)
      expect(page).to have_content(recipe3.title)
    end

    it 'updates recipes list with recipes having changed rating' do
      page.find('#recipes-rating-slider').set('4')
      page.find('#recipes-rating-slider').set('4.1')

      expect(page).to have_content(recipe3.title)
    end
  end

  context 'when user filters by ingredients and rating' do
    it 'updates recipes list with selected ingredient and rating' do
      page.find('.ingredient-filter-btn[data-ingredient-id="1"]').click
      page.find('#recipes-rating-slider').set('4.1')

      expect(page).not_to have_content(recipe1.title)
      expect(page).not_to have_content(recipe2.title)
      expect(page).to have_content(recipe3.title)
    end

    it 'updates recipes list with selected ingredient, rating, and another ingredient' do
      page.find('.ingredient-filter-btn[data-ingredient-id="1"]').click
      page.find('#recipes-rating-slider').set('4.1')
      page.find('.ingredient-filter-btn[data-ingredient-id="2"]').click

      expect(page).not_to have_content(recipe1.title)
      expect(page).not_to have_content(recipe2.title)
      expect(page).to have_content(recipe3.title)
    end
  end

  context 'when user resets filters' do
    it 'updates recipes list and shows all recipes after selecting an ingredient and resetting filters' do
      page.find('.ingredient-filter-btn[data-ingredient-id="1"]').click
      page.find('#reset-filters').click

      expect(page).to have_content(recipe1.title)
      expect(page).to have_content(recipe2.title)
      expect(page).to have_content(recipe3.title)
    end

    it 'updates recipes list and shows all recipes after selecting a rating and resetting filters' do
      page.find('#recipes-rating-slider').set('5')
      page.find('#reset-filters').click

      expect(page).to have_content(recipe1.title)
      expect(page).to have_content(recipe2.title)
      expect(page).to have_content(recipe3.title)
    end

    it 'updates recipes list and shows all recipes after selecting an ingredient, rating, and resetting filters' do
      page.find('.ingredient-filter-btn[data-ingredient-id="1"]').click
      page.find('.ingredient-filter-btn[data-ingredient-id="2"]').click
      page.find('.ingredient-filter-btn[data-ingredient-id="3"]').click
      page.find('#recipes-rating-slider').set('5')
      page.find('#reset-filters').click

      expect(page).to have_content(recipe1.title)
      expect(page).to have_content(recipe2.title)
      expect(page).to have_content(recipe3.title)
    end
  end
end
