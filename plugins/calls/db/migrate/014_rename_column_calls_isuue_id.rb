class RenameColumnCallsIsuueId < ActiveRecord::Migration
  def self.up
    rename_column :calls, :isuue_id, :issu_id
  end
  def self.down
    rename_column :calls, :issu_id, :isuue_id
  end
end
