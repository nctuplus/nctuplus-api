class RemoveContentInBulletins < ActiveRecord::Migration[5.2]
  def change
    remove_column :bulletins, :content, :strin
  end
end
