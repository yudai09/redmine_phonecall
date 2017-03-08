class ChangeColumn2EscalationRules < ActiveRecord::Migration
  change_column(:escalation_rules, :timeout, :integer, :null => false)
  change_column(:escalation_rules, :priority, :integer, :null => false)
end
