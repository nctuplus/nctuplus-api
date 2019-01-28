class CreateSlogans < ActiveRecord::Migration[5.2]
  def change
    create_table :slogans do |t|
      t.text :title
      t.boolean :display, default: false
      t.integer :author_id

      t.timestamps
    end
  end
end
