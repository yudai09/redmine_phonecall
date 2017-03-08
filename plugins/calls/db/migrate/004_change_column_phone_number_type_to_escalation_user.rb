class ChangeColumnPhoneNumberTypeToEscalationUser < ActiveRecord::Migration
  def change
    change_column :escalation_users, :phone_number, :string
  end
end
