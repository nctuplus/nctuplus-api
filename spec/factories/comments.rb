FactoryBot.define do
  factory :comment do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    anonymity { [false, true].sample }
  end

  factory :comment_for_rspec_test, parent: :comment do
    user { create(:user) }
    course { create(:course_for_rspec_test) }
  end
end
