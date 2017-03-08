class RenameColumnCallsIssuId < ActiveRecord::Migration
  def self.up
    rename_column :calls, :issu_id, :issue_id
  end
  def self.down
    rename_column :calls, :issue_id, :issu_id
  end
end
