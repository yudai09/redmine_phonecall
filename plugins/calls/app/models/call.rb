require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'

class Call < ActiveRecord::Base
  unloadable
  after_initialize :set_call_setting

  WATE_TIME = 5

  def calling(issue)
      @escalation_rules.each do |escalation_rule|
        @escalation_users.each do |escalation_user|
          Rails.logger.info(escalation_rule.inspect)
          Rails.logger.info(escalation_user.inspect)
  
          # calling
          calling = @client.account.calls.create({
            :url => @twilio_setting.respons_url,
            :to => escalation_user.phone_number.sub(/^0/, '+81'),
            :from => @twilio_setting.twilio_phone_number.sub(/^0/, '+81'),
            :timeout => escalation_rule.timeout
          })
  
          # wait
          sleep(escalation_rule.timeout + WATE_TIME)
  
          # call_status check
          calling_status = @client.account.calls.get(calling.sid).status
          Rails.logger.info(calling_status)
  
          case calling_status
          when 'completed'
            # チケット更新
            notes = "#{escalation_user.name}が着信"
            save_issue_and_journal(issue, notes)
            return true
          when 'queued','ringing','in-progress','busy','failed','no-answer','canceled'
            next
          else
          　next
          end 
        end
      end
    #エスカレーションで誰も出ない場合
    return false
  end

private
  
  # エスカレーションルール設定
  def set_call_setting
    @twilio_setting = TwilioSetting.find(1)
    @escalation_rules = EscalationRule.select(:timeout).order(:priority)
    @escalation_users = EscalationUser.select(:name,:phone_number).order(:priority)
    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new @twilio_setting.account_sid, @twilio_setting.auth_token
  end

　# チケット更新＋履歴登録
　def save_issue_and_journal(issue, notes)
    issue.touch # updated_atのみ更新
    if issue.update()
      # 履歴登録
      journal = Journal.new(
        :journalized => issue, 
        :journalized_id => issue.id, 
        :notes => notes, 
        :user_id => 1 ) # 1=admin TODO user_idとescalation_user_idをあわせる
      journal.save 
    else
      raise ActiveRecord::Rollback
    end
  end
end
