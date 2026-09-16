class CreateAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :availabilities do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :start_at
      t.datetime :end_at
      t.string :note

      t.timestamps
    end
  end
end
