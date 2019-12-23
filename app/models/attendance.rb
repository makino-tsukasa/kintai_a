class Attendance < ApplicationRecord
  belongs_to :user
  
  enum request_to: { "上長ユーザー1" => 2, "上長ユーザー2" => 3 }, _prefix: true
  enum status: { "なし" => 1, "申請中" => 2, "承認" => 3, "否認" => 4 }, _prefix: true
  
  enum oneday_attendance_request_to: { "上長ユーザー1" => 2, "上長ユーザー2" => 3 }, _prefix: true
  enum oneday_attendance_status: { "なし" => 1, "申請中" => 2, "承認" => 3, "否認" => 4 }, _prefix: true
  
  enum monthly_approvement_to: { "上長ユーザー1" => 2, "上長ユーザー2" => 3 }, _prefix: true
  enum monthly_approvement_status: { "なし" => 1, "申請中" => 2, "承認" => 3, "否認" => 4 }, _prefix: true
  
  validates :approve, acceptance: true
  validates :next_day, acceptance: true
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  validates :details_of_tasks, length: { maximum: 250 }
  
  validate :finished_at_is_invalid_without_a_started_at
  validate :finished_at_must_be_later_than_started_at
  
  validate :request_finished_at_is_invalid_without_a_request_started_at
  validate :request_started_at_is_invalid_without_a_request_finished_at
  validate :request_finished_at_must_be_later_than_request_started_at
  validate :expecting_finish_time_must_be_later_than_redesignated_endtime

  # 出勤時間が存在しない場合、退勤時間は無効
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  # 出勤時間より早い退勤時間は無効
  def finished_at_must_be_later_than_started_at
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
  
  # 出勤時間が存在しない場合、退勤時間は無効（一日分の勤怠変更申請）
  def request_finished_at_is_invalid_without_a_request_started_at
    errors.add(:request_started_at, "が必要です") if request_started_at.blank? && request_finished_at.present?
  end
  
  # 退勤時間が存在しない場合、出勤時間は無効（一日分の勤怠変更申請）
  def request_started_at_is_invalid_without_a_request_finished_at
    errors.add(:request_finished_at, "が必要です") if request_finished_at.blank? && request_started_at.present?
  end
  
  # 出勤時間より早い退勤時間は無効（一日分の勤怠変更申請）
  def request_finished_at_must_be_later_than_request_started_at
    if request_started_at.present? && request_finished_at.present?
      errors.add(:request_started_at, "より早い退勤時間は無効です") if request_started_at > request_finished_at
    end
  end
  
  # 残業申請：指定勤務終了時間より早い終了予定時間での申請不可
  def expecting_finish_time_must_be_later_than_redesignated_endtime
    if expecting_finish_time.present? && redesignated_endtime.present?
      errors.add(:redesignated_endtime, "より早い終了予定時間での申請は無効です") if expecting_finish_time < redesignated_endtime
    end
  end
end
