class AddAnonymityToPastExams < ActiveRecord::Migration[5.2]
  def change
  	add_column :past_exams, :anonymity, :boolean, default: false
  end
end
