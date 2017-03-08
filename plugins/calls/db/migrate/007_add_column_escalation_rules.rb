class AddColumnEscalationRules < ActiveRecord::Migration
  def change
    add_timestamps(:escalation_rules)
  end
end
