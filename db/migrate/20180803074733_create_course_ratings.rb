class CreateCourseRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :course_ratings do |t|
      t.belongs_to :course, index: true
      t.belongs_to :user, index: true
      t.integer :category
      t.integer :score
      t.timestamps
    end
  end
end
