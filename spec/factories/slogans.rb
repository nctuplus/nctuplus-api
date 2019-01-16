FactoryBot.define do
  factory :slogan do
    title { "Hello Moto" }
    display { false }
    author { create :user }
  end
end
