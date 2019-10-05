class CreateBases < ActiveRecord::Migration[5.1]
  def change
    create_table :bases do |t|
      t.integer :base_number
      t.string :base_name
      t.string :type_of_attendance

      t.timestamps
    end
  end
end
