class DeleteStatusInBooks < ActiveRecord::Migration[5.2]
  def change
    remove_column :books, :status, :integer
  end
end
