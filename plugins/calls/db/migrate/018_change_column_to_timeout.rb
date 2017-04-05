class ChangeColumnToTimeout < ActiveRecord::Migration
  def up
    change_column :escalation_rules, :timeout, :integer, null: false, default: 1
  end
  
  def down
    change_column :escalation_rules, :timeout, :integer
  end
end
