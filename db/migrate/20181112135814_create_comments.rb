class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.string :title
      t.text :content
      t.integer :course_id
      t.integer :user_id
      t.boolean :anonymity

      t.timestamps
    end
  end
end
