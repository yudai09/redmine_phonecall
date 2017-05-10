class AddUniqueIndexUserIdToEscalationUsers < ActiveRecord::Migration
  def change
    add_index :escalation_users, :user_id, :unique => true, :name => 'unique_user_id'
  end
end
