FactoryBot.define do
  factory :course_rating do
    category { Faker::Number.between(0, 2) }
    score { Faker::Number.between(0, 5) }
    user { create(:user) }
  end
end
