class Availability < ApplicationRecord
  belongs_to :user

  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :end_after_start
  validate :does_not_overlap_confirmed_interview

  scope :overlapping, ->(start_at, end_at) { where("start_at < ? AND end_at > ?", end_at, start_at) }

  private

  def end_after_start
    return if start_at.blank? || end_at.blank?

    errors.add(:end_at, "は開始時刻より後の時刻にしてください") if end_at <= start_at
  end

  # 「空いている」の判定は、この予定(availabilities)と確定済み面接(interviews)の
  # 両方を見て行っている(User#available_at?)。その逆方向、つまりこの予定を追加・変更する側でも
  # 確定済みの面接と重ならないかをチェックしないと、同じ時間帯に「面接がある」のに
  # 「予定を追加できてしまう」という矛盾したデータができてしまう。
  def does_not_overlap_confirmed_interview
    return if start_at.blank? || end_at.blank? || user.blank?

    conflicting = user.interviews.confirmed.overlapping(start_at, end_at)
    return unless conflicting.exists?

    errors.add(:base, "この時間帯にはすでに確定済みの面接が入っています(#{conflicting.first.scheduled_start_at.strftime('%m/%d %H:%M')}〜#{conflicting.first.scheduled_end_at.strftime('%H:%M')})。先に面接をキャンセル・変更するか、時間をずらしてください")
  end
end
