class ChangeNameToEscalationUsers < ActiveRecord::Migration
  def change
    remove_column :escalation_users,:name 
    add_column :escalation_users, :user_id, :integer, :null => false
  end
end
