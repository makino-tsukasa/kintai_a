class Attendance < ApplicationRecord
  belongs_to :user
  
  enum request_to: { "上長ユーザー1" => 2, "上長ユーザー2" => 3 }, _prefix: true
  enum status: { "なし" => 1, "申請中" => 2, "承認" => 3, "否認" => 4 }, _prefix: true
  
  enum oneday_attendance_request_to: { "上長ユーザー1" => 2, "上長ユーザー2" => 3 }, _prefix: true
  enum oneday_attendance_status: { "なし" => 1, "申請中" => 2, "承認" => 3, "否認" => 4 }, _prefix: true
  
  validates :approve, acceptance: true
  validates :next_day, acceptance: true
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  validates :details_of_tasks, length: { maximum: 250 }
  
  validate :finished_at_is_invalid_without_a_started_at
  validate :finished_at_must_be_later_than_started_at

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
end
