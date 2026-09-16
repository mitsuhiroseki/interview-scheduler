# 稼働時間帯・休憩時間・面接時間の設定。
# 現時点では常に1件だけ存在する設定として扱う(将来、曜日別などに拡張する余地を残している)。
class BusinessHour < ApplicationRecord
  DEFAULTS = {
    start_time: "10:00",
    end_time: "19:00",
    break_start_time: "12:00",
    break_end_time: "13:00",
    interview_duration_minutes: 60,
    slot_interval_minutes: 15
  }.freeze

  def self.current
    first || create!(DEFAULTS)
  end

  # ある日付に対して、面接を開始できる時刻の候補一覧(稼働時間帯・休憩時間を考慮)を返す。
  def slot_start_times_for(date)
    slots = []
    time = date.to_time.change(hour: start_time.hour, min: start_time.min)
    day_end = date.to_time.change(hour: end_time.hour, min: end_time.min)
    duration = interview_duration_minutes.minutes

    while time + duration <= day_end
      unless overlaps_break?(time, time + duration)
        slots << time
      end
      time += slot_interval_minutes.minutes
    end

    slots
  end

  private

  def overlaps_break?(start_at, end_at)
    break_start = start_at.change(hour: break_start_time.hour, min: break_start_time.min)
    break_end = start_at.change(hour: break_end_time.hour, min: break_end_time.min)
    start_at < break_end && break_start < end_at
  end
end
