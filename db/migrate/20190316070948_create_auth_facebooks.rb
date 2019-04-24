class CreateAuthFacebooks < ActiveRecord::Migration[5.2]
  def change
    create_table :auth_facebooks do |t|
      t.integer :user_id
      t.string :uid, null: false
      t.string :name, null: false
      t.string :email, null: false
      t.string :image_url

      t.timestamps
    end
  end
end
