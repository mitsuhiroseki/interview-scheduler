class AddCandidateToInterviews < ActiveRecord::Migration[8.1]
  def change
    remove_column :interviews, :candidate_label, :string
    add_reference :interviews, :candidate, null: false, foreign_key: true
  end
end
