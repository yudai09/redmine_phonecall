class AddColumnCalls < ActiveRecord::Migration
  def change
    add_timestamps(:calls)
    change_column :calls, :created_at, :timestamp, null: false
    change_column :calls, :updated_at, :timestamp, null: false

    add_column :calls, :isuue_id, :integer, :null => false
  end
end
