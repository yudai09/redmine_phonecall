class CreateTwilioSettings < ActiveRecord::Migration
  def change
    create_table :twilio_settings do |t|
      t.string :twilio_phone_number, :null => false, :limit => 11
      t.string :account_sid, :null => false, :limit => 256
      t.string :auth_token, :null => false, :limit => 256
      t.string :respons_url, :limit => 256
    end
  end
end
