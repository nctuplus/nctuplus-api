class CreateAuthGoogles < ActiveRecord::Migration[5.2]
  def change
    create_table :auth_googles do |t|
      t.string :uid, null: false
      t.integer :user_id
      t.string :email, null: false
      t.string :name, null: false
      t.string :image_url

      t.timestamps
    end
  end
end
