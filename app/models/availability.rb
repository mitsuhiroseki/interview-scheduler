class Availability < ApplicationRecord
  belongs_to :user

  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :end_after_start

  scope :overlapping, ->(start_at, end_at) { where("start_at < ? AND end_at > ?", end_at, start_at) }

  private

  def end_after_start
    return if start_at.blank? || end_at.blank?

    errors.add(:end_at, "は開始時刻より後の時刻にしてください") if end_at <= start_at
  end
end
