class CreateBusinessHours < ActiveRecord::Migration[8.1]
  def change
    create_table :business_hours do |t|
      t.time :start_time
      t.time :end_time
      t.time :break_start_time
      t.time :break_end_time
      t.integer :interview_duration_minutes
      t.integer :slot_interval_minutes

      t.timestamps
    end
  end
end
