class AddDepartmentIdToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :department_id, :integer
  end
end
