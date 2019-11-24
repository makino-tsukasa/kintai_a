class RemoveColumnFromAttendances < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendances, :status, :enum
  end
end
