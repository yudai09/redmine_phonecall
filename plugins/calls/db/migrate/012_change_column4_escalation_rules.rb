class ChangeColumn4EscalationRules < ActiveRecord::Migration
  def change
    change_column :escalation_rules, :created_at, :timestamp, null: false
    change_column :escalation_rules, :updated_at, :timestamp, null: false
  end
end
