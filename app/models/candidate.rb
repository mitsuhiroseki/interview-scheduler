class Candidate < ApplicationRecord
  has_many :interviews

  validates :name, presence: true
end
