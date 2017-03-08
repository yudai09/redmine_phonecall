class ChangeColumnPhoneNumberToEscalationUser < ActiveRecord::Migration
  def change
    change_column :escalation_users, :phone_number, :integer
  end
end
