FactoryBot.define do
  factory :permanent_course do
    name { Faker::Educator.course_name }
    code { ('A'..'Z').to_a.sample(3).join + Faker::Number.between(1000, 9999).to_s }
    description { Faker::Lorem.sentence }
  end
end
