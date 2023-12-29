# frozen_string_literal: true

class AddMealdbIdToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :mealdb_id, :integer
  end
end
