FactoryBot.define do
  factory :reply do
    user_id { 1 }
    content { "MyText" }
    anonymity { false }
  end
end
