class AddMonthlyApprovementToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :monthly_approvement_status, :integer
    add_column :attendances, :monthly_approvement_to, :integer
  end
end
