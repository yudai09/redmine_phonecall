class CreateEscalationUsers < ActiveRecord::Migration
  def change
    create_table :escalation_users do |t|
      t.string :name, :limit => 256, :null => false
      t.string :phone_number, :limit => 256, :null => false
      t.integer :priority, :null => false, :default => 0
    end
  end
end
