FactoryBot.define do
  factory :slogan do
    title { Faker::Lorem.sentence }
    display { [false, true].sample }
    author { create :user }
  end
end
