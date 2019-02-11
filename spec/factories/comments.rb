FactoryBot.define do
  factory :comment do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    course { create(:course) }
    user { create(:user) }
    anonymity { [false, true].sample }
  end
end
