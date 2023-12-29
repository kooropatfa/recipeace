# frozen_string_literal: true

FactoryBot.define do
  factory :recipe do
    title { Faker::Food.dish }
    instructions { 'Mash it all together. Gently.' }

    trait :with_3_ingredients do
      after(:create) do |recipe|
        create_list(:recipe_ingredient, 3, recipe: recipe)
      end
    end

    trait :with_3_ratings do
      after(:create) do |recipe|
        create_list(:recipe_rating, 3, recipe: recipe)
      end
    end
  end
end
