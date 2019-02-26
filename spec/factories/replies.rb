FactoryBot.define do
  factory :reply do
    content { Faker::Lorem.paragraph }
    anonymity { [true, false].sample }
  end

  factory :reply_for_rspec_test, parent: :reply do
    user { FactoryBot.create :user }
    comment { FactoryBot.create :comment_for_rspec_test }
  end
end
