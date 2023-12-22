# frozen_string_literal: true

FactoryBot.define do
  factory :recipe_rating do
    value { 4 }
    recipe { association :recipe }
  end
end