# 開発用のマスターデータ。
# 6名の担当者(採用担当 兼 面接官)と、稼働時間帯の設定だけを用意する。
# すべてパスワードは "password" 。
#
# 個人の予定(availabilities)や面接(interviews)はここでは自動生成しない。
# デモ・動作確認用のデータは、アプリの画面(自分の予定 登録画面、日程検索画面)から
# 自分で入力する運用にする。

BusinessHour.current

USERS = [
  { name: "佐藤 一郎",   email: "sato@example.com" },
  { name: "鈴木 花子",   email: "suzuki@example.com" },
  { name: "高橋 健太",   email: "takahashi@example.com" },
  { name: "田中 美咲",   email: "tanaka@example.com" },
  { name: "伊藤 直樹",   email: "ito@example.com" },
  { name: "渡辺 愛",     email: "watanabe@example.com" }
].freeze

USERS.each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name = attrs[:name]
    u.password = "password"
    u.password_confirmation = "password"
  end
end

puts "ユーザーを#{User.count}件作成しました(全員パスワード: password)"
puts "稼働時間帯の設定: #{BusinessHour.current.start_time.strftime('%H:%M')}〜#{BusinessHour.current.end_time.strftime('%H:%M')}"
