# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Create fake user data
users = FactoryBot.create_list :user, 20

# Create department fake data
departments = FactoryBot.create_list :department, 10 unless Department.all.length >= 30

# Create semester fake data
semesters = FactoryBot.create_list :semester, 10 unless Semester.all.length >= 30

# Create permanent course fake data
25.times { FactoryBot.create :permanent_course } unless PermanentCourse.all.length >= 75

# Create course fake data based on the existing permanent course fake data
PermanentCourse.all.each do |permanent_course|
  4.times do
    course = FactoryBot.create :course, permanent_course: permanent_course, department: departments.sample
    course.semester = semesters.sample
    course.teachers << FactoryBot.create_list(:teacher, [1, 2, 3].sample)
    course.save

    # Create associated fake comments and course ratings data
    (0..3).to_a.sample.times do
      comment = FactoryBot.create :comment, course: course, user: users.sample
      3.times do |i|
        comment.user.course_ratings.create FactoryBot.attributes_for :course_rating, category: i, course: course
      end
    end

    # Create associated fake scores and users course data
    3.times do
      FactoryBot.create :score, course: course, user: users.sample
      course.users << users.sample
    end
  end
end

courses = Course.all

100.times do
  book = FactoryBot.create :book
  book.courses << courses.sample([1, 2, 3, 4].sample)
end

100.times { FactoryBot.create :past_exam, course: courses.sample } unless PastExam.count >= 1000
10.times { FactoryBot.create :event } unless Event.all.size >= 50

30.times { FactoryBot.create :bulletin } unless Bulletin.all.size >= 50
30.times { FactoryBot.create :background } unless Background.all.size >= 150
30.times { FactoryBot.create :slogan } unless Slogan.all.length >= 150

FactoryBot.create :test_user unless User.find_by_name(:test).present?
FactoryBot.create :admin_user unless User.find_by_name(:admin).present?
