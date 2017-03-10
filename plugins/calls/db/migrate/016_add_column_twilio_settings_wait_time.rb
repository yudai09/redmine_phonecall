class AddColumnTwilioSettingsWaitTime < ActiveRecord::Migration
  def change
    add_column :twilio_settings, :wait_time, :integer, :null => false, :limit => 2, :default => 10
  end
end
