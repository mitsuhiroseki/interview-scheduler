class Interview < ApplicationRecord
  STATUSES = %w[confirmed cancelled].freeze

  belongs_to :created_by, class_name: "User"
  belongs_to :candidate
  has_many :interview_assignments, dependent: :destroy
  has_many :users, through: :interview_assignments

  validates :scheduled_start_at, presence: true
  validates :scheduled_end_at, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :confirmed, -> { where(status: "confirmed") }
  scope :overlapping, ->(start_at, end_at) { where("scheduled_start_at < ? AND scheduled_end_at > ?", end_at, start_at) }

  def cancel!
    update!(status: "cancelled")
  end
end
