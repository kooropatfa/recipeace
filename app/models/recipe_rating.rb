# frozen_string_literal: true

class RecipeRating < ApplicationRecord
  belongs_to :recipe

  validates :value, presence: true, inclusion: { in: 0..5 }
end
