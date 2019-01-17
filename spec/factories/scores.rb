FactoryBot.define do
  factory :score do
    user { create(:user) }
    course { create(:course) }
    score { [Faker::Number.between(0, 100).to_s, 'W', '\u901a\u904e', '\u4e0d\u901a\u904e'].sample }
  end
end
