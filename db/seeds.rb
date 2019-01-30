# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

unless Course.all.size >= 1000
  100.times do
    FactoryBot.create :course
  end
end

100.times { FactoryBot.create :book } unless Book.all.size >= 1000
100.times { FactoryBot.create :past_exam } unless PastExam.all.size >= 1000
10.times { FactoryBot.create :event } unless Event.all.size >= 50
unless Comment.all.length >= 50
  20.times do
    comment = FactoryBot.create :comment
    [1, 2, 3].sample.times { comment.course.teachers << FactoryBot.create(:teacher) }
    3.times do |i|
      comment.user.course_ratings.create FactoryBot.attributes_for :course_rating, category: i, course: comment.course
    end
  end
end
30.times { FactoryBot.create :bulletin } unless Bulletin.all.size >= 50
30.times { FactoryBot.create :background } unless Background.all.size >= 150
30.times { FactoryBot.create :slogan } unless Slogan.all.length >= 150

FactoryBot.create :test_user unless User.find_by_name(:test).present?
FactoryBot.create :admin_user unless User.find_by_name(:admin).present?
