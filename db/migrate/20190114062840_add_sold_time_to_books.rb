class AddSoldTimeToBooks < ActiveRecord::Migration[5.2]
  def change
    add_column :books, :sold_at, :datetime, default: nil
  end
end
