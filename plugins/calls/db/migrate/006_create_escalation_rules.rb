class CreateEscalationRules < ActiveRecord::Migration
  def change
    create_table :escalation_rules do |t|
      t.integer :timeout, :limit => 2
      t.integer :priority, :limit => 1
    end
  end
end
