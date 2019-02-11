class CreateScores < ActiveRecord::Migration[5.2]
  def change
    create_table :scores do |t|
      t.integer :user_id
      t.integer :course_id
      t.string :score

      t.timestamps
    end
  end
end
