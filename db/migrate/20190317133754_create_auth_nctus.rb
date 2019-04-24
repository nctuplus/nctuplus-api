class CreateAuthNctus < ActiveRecord::Migration[5.2]
  def change
    create_table :auth_nctus do |t|
      t.string :student_id, null: false
      t.string :name, null: false
      t.string :email, null: false
      t.integer :user_id

      t.timestamps
    end
  end
end
