class InterviewsController < ApplicationController
  before_action :set_interview, only: %i[show edit update cancel]

  # 予約一覧には確定済みの予約のみを表示する(キャンセル済みは表示しない)。
  def index
    @interviews = Interview.confirmed.includes(:users, :created_by).order(scheduled_start_at: :desc)
  end

  def show
  end

  # 日程検索画面(scheduling#new)の比較結果から呼ばれる。
  # 予約確定時に、選択された担当者が「本当に今も空いているか」をサーバー側で再チェックする。
  # これにより、複数人が同時に同じ担当者へアサインしようとした場合のダブルブッキングを防ぐ。
  # 失敗した場合は、元の検索条件(候補者名・候補日時一覧)を付けたまま検索画面に戻し、
  # 最新の空き状況をその場で見直せるようにする。
  def create
    candidate_name = params[:candidate_name]
    user_ids = Array(params.dig(:interview, :user_ids)).reject(&:blank?).map(&:to_i)
    start_at = params.dig(:interview, :scheduled_start_at)
    end_at = params.dig(:interview, :scheduled_end_at)

    if candidate_name.blank?
      redirect_to search_retry_path(params), alert: "候補者名を入力してください"
      return
    end

    if user_ids.empty?
      redirect_to search_retry_path(params), alert: "担当者を1人以上選択してください"
      return
    end

    @interview = Interview.new(
      candidate: Candidate.new(name: candidate_name),
      scheduled_start_at: start_at,
      scheduled_end_at: end_at,
      status: "confirmed",
      created_by: current_user
    )

    unavailable_names = []

    ActiveRecord::Base.transaction do
      unavailable = User.where(id: user_ids).select do |user|
        !user.available_at?(@interview.scheduled_start_at, @interview.scheduled_end_at)
      end

      if unavailable.any?
        unavailable_names = unavailable.map(&:name)
        raise ActiveRecord::Rollback
      end

      @interview.save!
      user_ids.each { |uid| @interview.interview_assignments.create!(user_id: uid) }
    end

    if unavailable_names.any?
      redirect_to search_retry_path(params),
                  alert: "#{unavailable_names.join('、')}さんは、この時間帯にすでに予定が入っています(他の担当者が先に確定した可能性があります。最新の空き状況を確認してください)"
    else
      redirect_to interviews_path, notice: "面接を確定しました"
    end
  end

  def edit
  end

  # 日程変更。新しい日時に、現在アサインされている担当者が空いているかを再チェックする。
  # 面接時間は business_hours の設定(60分)を維持し、開始時刻だけを変更する。
  def update
    new_start = params.dig(:interview, :scheduled_start_at)

    if new_start.blank?
      flash.now[:alert] = "日時を入力してください"
      render :edit, status: :unprocessable_entity
      return
    end

    new_end = Time.zone.parse(new_start) + BusinessHour.current.interview_duration_minutes.minutes

    conflicting = @interview.users.select do |user|
      !user_available_ignoring_current_interview?(user, new_start, new_end)
    end

    if conflicting.any?
      flash.now[:alert] = "#{conflicting.map(&:name).join('、')}さんは、その時間帯にすでに予定が入っています"
      render :edit, status: :unprocessable_entity
      return
    end

    if @interview.update(scheduled_start_at: new_start, scheduled_end_at: new_end)
      redirect_to interview_path(@interview), notice: "日程を変更しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel
    @interview.cancel!
    redirect_to interviews_path, notice: "予約をキャンセルしました"
  end

  private

  def set_interview
    @interview = Interview.find(params[:id])
  end

  # 確定に失敗したとき、元の検索条件(候補者名・候補日時一覧)を保ったまま
  # 検索画面(scheduling#new)に戻すためのURLを組み立てる。
  def search_retry_path(params)
    new_schedule_path(
      candidate_name: params[:candidate_name],
      requested_dates: params[:requested_dates],
      requested_times: params[:requested_times]
    )
  end

  # 変更対象の面接自身の予約とは重複しても無視して判定する(自分自身とはぶつからないようにする)
  def user_available_ignoring_current_interview?(user, start_at, end_at)
    return false if user.availabilities.overlapping(start_at, end_at).exists?

    Interview.confirmed.where.not(id: @interview.id).overlapping(start_at, end_at)
             .joins(:interview_assignments)
             .where(interview_assignments: { user_id: user.id })
             .none?
  end
end
