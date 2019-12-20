class AddOnedayRequestColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :first_started_at, :datetime
    add_column :attendances, :first_finished_at, :datetime
    add_column :attendances, :request_started_at, :datetime
    add_column :attendances, :request_finished_at, :datetime
    add_column :attendances, :oneday_attendance_request_to, :integer
    add_column :attendances, :oneday_attendance_status, :integer
    add_column :attendances, :date_of_approvement, :datetime
  end
end
