require 'csv'
require 'date'

CSV.generate do |csv|
  column_names = %w(日付 出勤時間 退勤時間)
  csv << column_names
  @attendances.each do |attendance|
    column_values = [
      attendance.worked_on.strftime("%Y年%-m月%-d日"),
      if attendance.started_at.present?
        attendance.started_at.strftime("%R")
      end,
      if attendance.finished_at.present?
        attendance.finished_at.strftime("%R")
      end
    ]
    csv << column_values
  end
end