class User < ApplicationRecord
  has_secure_password

  has_many :availabilities, dependent: :destroy
  has_many :interview_assignments, dependent: :destroy
  has_many :interviews, through: :interview_assignments
  has_many :created_interviews, class_name: "Interview", foreign_key: :created_by_id, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  # 指定した時間帯にこの担当者が空いているかどうかを判定する。
  # 「自分の予定」「確定済みの面接」のどちらとも重ならなければ空いているとみなす。
  def available_at?(start_at, end_at)
    return false if availabilities.overlapping(start_at, end_at).exists?
    return false if Interview.confirmed.overlapping(start_at, end_at)
                             .joins(:interview_assignments)
                             .where(interview_assignments: { user_id: id })
                             .exists?

    true
  end
end
