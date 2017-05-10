class AddRelationEscalationUsersToUsers < ActiveRecord::Migration
  def change
    remove_column :escalation_users, :user_id
    add_reference :escalation_users, :user, index: true
    add_foreign_key :escalation_users, :users
  end
end
