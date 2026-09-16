class CreateInterviews < ActiveRecord::Migration[8.1]
  def change
    create_table :interviews do |t|
      t.string :candidate_label
      t.datetime :scheduled_start_at
      t.datetime :scheduled_end_at
      t.string :status
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
