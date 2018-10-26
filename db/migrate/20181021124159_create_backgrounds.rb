class CreateBackgrounds < ActiveRecord::Migration[5.2]
  def change
    drop_table :backgrounds
    create_table :backgrounds do |t|
      t.string :cover_image
      t.references :author, references: :users, index: true
      t.timestamps
    end
  end
end
