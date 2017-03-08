class ChangeColumnEscalationRules < ActiveRecord::Migration
  change_table :escalation_rules do |t|
    t.integer null: false
  end
end
