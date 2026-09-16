class CreateInterviewAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :interview_assignments do |t|
      t.references :interview, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
