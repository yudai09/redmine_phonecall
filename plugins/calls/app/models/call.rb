require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'

class Call < ActiveRecord::Base
  unloadable
  after_initialize :set_call_setting

  def escalation(issue)
    Rails.logger.info("Processing by Call Escalation")
    # エスカレーション
    @escalation_rules.each.with_index(1) do |escalation_rule, escalation_index|
      @escalation_users.each do |escalation_user|
        Rails.logger.info("  Escalation Info: round = #{escalation_index},user = #{escalation_user.name}")
        # 発信
        begin
          calling = @client.account.calls.create({
              :url => @twilio_setting.respons_url,
              :to => escalation_user.phone_number.sub(/^0/, '+81'),
              :from => @twilio_setting.twilio_phone_number.sub(/^0/, '+81'),
              :timeout => escalation_rule.timeout})
        rescue Twilio::REST::RequestError => e
          Rails.logger.info(e.message)
        end

        # Wait
        sleep(escalation_rule.timeout + @twilio_setting.wait_time)

        # Status Check
        result = @client.account.calls.get(calling.sid)
        Rails.logger.info("  Escalation Info: status=#{result.status},time=#{convert_time(result.date_updated)}")
        @notes = make_notes(escalation_rule, escalation_user, escalation_index, result)
        case result.status
        when 'completed'  # 通話成功
          save_issue_and_journal(issue, @notes)
          return
        when 'failed'     # 通話失敗
          save_issue_and_journal(issue, @notes) 
          next
        when 'queued','ringing'
          next #TODO 数回リトライできるようにする
        else # 'in-progress','busy','failed','no-answer','canceled' or other
          next
        end 
      end
    end
    #エスカレーションで誰も出ない場合
    save_issue_and_journal(issue, @notes)
  end

  private
  
  # エスカレーション設定
  def set_call_setting
    @twilio_setting = TwilioSetting.find(1)
    @escalation_rules = EscalationRule.select(:timeout).order(:priority)
    @escalation_users = EscalationUser.select(:name,:phone_number).order(:priority)
    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new @twilio_setting.account_sid, @twilio_setting.auth_token
  end

  # チケット更新＋履歴登録
  def save_issue_and_journal(issue, notes)
    # チケットはupdated_atのみ更新
    issue.touch
    # 履歴生成
    journal = Journal.new(:journalized => issue, 
        :journalized_id => issue.id, 
        :notes => notes, 
        :user_id => User.current.id )
    
    Issue.transaction do      
      if !issue.save or !journal.save then
        raise ActiveRecord::Rollback
      end
    end
  end
  
  # 時刻変換 
  def convert_time(time_str)
    return Time.parse(time_str).in_time_zone("Asia/Tokyo").strftime('%Y年%m月%d日 %H:%M:%S')
  end
  
  # 履歴文言生成
  def make_notes(escalation_rule, escalation_user, escalation_index, result)
    notes = ''
    case result.status
    when 'completed'
      notes = "#{escalation_index}周目のエスカレーションで\
               #{escalation_user.name}が電話を取りました。\
               (#{convert_time(result.start_time)})"
    when 'failed'
      notes = "#{escalation_user.name}に通話を試みましが失敗しました。\
               電話番号が正しいか確認をしてください"
    else
      notes = "#{@escalation_users.size}人に#{@escalation_rules.size}回の\
               エスカレーションを行いましたが、誰も電話を取ることができませんでした。\
               再度エスカレーションを試みてください。"
    end
    return notes
  end
end
