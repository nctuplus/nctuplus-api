class CreateReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :replies do |t|
      t.integer :user_id, null: false
      t.integer :comment_id, null: false
      t.text :content, null: false
      t.boolean :anonymity, default: true

      t.timestamps
    end
  end
end
