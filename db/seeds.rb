# 開発用のダミーデータ。
# 6名の担当者(採用担当 兼 面接官)と、それぞれの予定(空いていない時間帯)を用意する。
# すべてパスワードは "password" 。

BusinessHour.current

USERS = [
  { name: "佐藤 一郎",   email: "sato@example.com" },
  { name: "鈴木 花子",   email: "suzuki@example.com" },
  { name: "高橋 健太",   email: "takahashi@example.com" },
  { name: "田中 美咲",   email: "tanaka@example.com" },
  { name: "伊藤 直樹",   email: "ito@example.com" },
  { name: "渡辺 愛",     email: "watanabe@example.com" }
].freeze

users = USERS.map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name = attrs[:name]
    u.password = "password"
    u.password_confirmation = "password"
  end
end

# 今日から2週間分、平日の午前・午後にランダムで「予定あり(空いていない)」を入れる
users.each do |user|
  (0..13).each do |offset|
    date = Date.current + offset.days
    next if date.saturday? || date.sunday?
    next unless rand < 0.4 # 4割くらいの確率で予定を入れる

    hour = [ 10, 11, 14, 15, 16, 17 ].sample
    start_at = date.to_time.change(hour: hour)
    end_at = start_at + 60.minutes

    Availability.find_or_create_by!(user: user, start_at: start_at, end_at: end_at) do |a|
      a.note = "既存の予定(ダミー)"
    end
  end
end

# デモ用に、確定済みの面接を1件だけ用意しておく(空の画面だと動作イメージが掴みにくいため)。
demo_start = (Date.current + 3.days).to_time.change(hour: 10)
demo_end = demo_start + BusinessHour.current.interview_duration_minutes.minutes
demo_interviewer = users.find { |u| u.available_at?(demo_start, demo_end) } || users.first

demo_candidate = Candidate.find_or_create_by!(name: "山田 太郎(デモ候補者)")
Interview.find_or_create_by!(candidate: demo_candidate, scheduled_start_at: demo_start) do |interview|
  interview.scheduled_end_at = demo_end
  interview.status = "confirmed"
  interview.created_by = users.first
  interview.interview_assignments.build(user: demo_interviewer)
end

puts "ユーザーを#{User.count}件作成しました(全員パスワード: password)"
puts "予定(availabilities)を#{Availability.count}件作成しました"
puts "デモ用の面接を#{Interview.count}件作成しました"
