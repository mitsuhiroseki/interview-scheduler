class CreateCandidates < ActiveRecord::Migration[8.1]
  def change
    create_table :candidates do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
