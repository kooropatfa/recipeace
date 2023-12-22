# frozen_string_literal: true

FactoryBot.define do
  factory :recipe_ingredient do
    quantity { 1 }
    recipe { association :recipe }
    ingredient { association :ingredient }
  end
end