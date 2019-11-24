class AddColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :request_to, :integer
    add_column :attendances, :status, :enum
  end
end
