class SchedulingController < ApplicationController
  SLOT_INPUT_COUNT = 5

  # 候補者からもらった希望日時(3〜5件)をまとめて入力すると、
  # それぞれの日時について対応できる担当者を一覧比較できる画面。
  # GETのクエリパラメータで状態を持たせているので、確定に失敗して戻ってきた場合や
  # ブラウザの再読み込みでも、同じ入力内容で最新の空き状況を再計算できる。
  def new
    return unless params[:candidate_name].present? || params[:requested_dates].present?

    @candidate_name = params[:candidate_name]
    @requested_dates = Array(params[:requested_dates])
    @requested_times = Array(params[:requested_times])
    slots = requested_slots

    if @candidate_name.blank?
      flash.now[:alert] = "候補者名を入力してください"
    elsif slots.empty?
      flash.now[:alert] = "候補日時を1つ以上、日付と時刻の両方を入力してください"
    else
      @business_hours = BusinessHour.current
      @results = slots.map do |slot_start|
        slot_end = slot_start + @business_hours.interview_duration_minutes.minutes
        available_users = User.order(:name).select { |user| user.available_at?(slot_start, slot_end) }
        { start_at: slot_start, end_at: slot_end, available_users: available_users }
      end
    end
  end

  private

  def requested_slots
    @requested_dates.zip(@requested_times).filter_map do |date, time|
      next if date.blank? || time.blank?

      Time.zone.parse("#{date} #{time}")
    rescue ArgumentError, TypeError
      nil
    end
  end
end
