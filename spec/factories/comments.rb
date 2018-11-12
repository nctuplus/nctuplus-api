FactoryBot.define do
  factory :comment do
    title { "MyString" }
    content { "MyText" }
    course_id { 1 }
    user_id { 1 }
    anonymity { false }
  end
end
