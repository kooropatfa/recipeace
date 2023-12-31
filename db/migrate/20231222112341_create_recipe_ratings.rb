# frozen_string_literal: true

class CreateRecipeRatings < ActiveRecord::Migration[7.0]
  def change
    create_table :recipe_ratings do |t|
      t.integer :value
      t.references :recipe, null: false, foreign_key: true

      t.timestamps
    end
  end
end
