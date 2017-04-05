class FixColumnEscalationRules < ActiveRecord::Migration
  def change

    # 削除
    remove_column :escalation_rules, :priority

    # 追加
    add_column :escalation_rules, :max_loop_count, :integer, :null => false, :limit => 2, :default => 1
    
  end
end
