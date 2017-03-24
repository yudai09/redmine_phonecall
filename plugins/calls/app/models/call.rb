require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'

class Call < ActiveRecord::Base
  unloadable
  after_initialize :set_call_setting

  WAITE_DELAY_TIME = 10
  MAX_AGAIN_COUNT = 1
  
  
  def call(issue, root_url)
    Rails.logger.info("Processing by Call")
    Rails.logger.info(@escalation_rule.inspect)
    # エスカレーション
    #for loop_count in 1..@escalation_rule.max_loop_count
    (1..@escalation_rule.max_loop_count).each.with_index(1) do |loop_count|
      @escalation_users.each do |escalation_user|
        Rails.logger.info("  Call Info: round = #{loop_count}, user = #{escalation_user.name}")
        again_count = 0
        # 発信
        if calling.nil?
          calling = to_call(escalation_user)
        end
        # Wait
        sleep(@escalation_rule.timeout + WAITE_DELAY_TIME)
        # ステータス取得
        result = get_call_result(calling)
        Rails.logger.info("  Call Info: status=#{result.status},time=#{convert_time(result.date_updated)}")
        
        # チケット文言生成 
        @notes = make_notes(escalation_user, result)
        
        case result.status
        when 'completed'  # 通話成功
          send_sms(escalation_user)
          save_issue_and_journal(issue, @notes)
          Rails.logger.info("    Success.")
          return
        when 'failed'     # 通話失敗
          save_issue_and_journal(issue, @notes)
          Rails.logger.info("    Failed. Next User")
          next
        when 'queued','ringing' # 通話待ち
          if again_count < MAX_AGAIN_COUNT
            again_count++
            Rails.logger.info("    Wating. Check Retry")
            redo # もう一度確認
          else
            Rails.logger.info("    Not start. Next User ")
            next
          end
        else # 'in-progress','busy,'no-answer','canceled' or other
          Rails.logger.info("    Not connected. Next User")
          next
        end
      end
        Rails.logger.info("  Next loop")
    end
    Rails.logger.info("  Call Info: No one answered the phone")
    save_issue_and_journal(issue, @notes)
  end

  private

  # エスカレーション設定
  def set_call_setting
    @twilio_setting = TwilioSetting.find(1)
    @escalation_rule = EscalationRule.find(1)
    @escalation_users = EscalationUser.select(:name,:phone_number).order(:priority)
    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new @twilio_setting.account_sid, @twilio_setting.auth_token
  end

  
  # Twilioで通知
  def to_call(escalation_user)
    calling = nil
    begin
      calling = @client.account.calls.create({
          :url => @twilio_setting.respons_url,
          :to => escalation_user.phone_number,
          :from => @twilio_setting.twilio_phone_number,
          :timeout => @escalation_rule.timeout})
      Rails.logger.info(calling.inspect)
    rescue Twilio::REST::RequestError => e
      Rails.logger.error("Twilio Request Error Call:#{e.backtrace.join("\n")}")
    end
    return calling
  end
  
  # SMS通知
  def send_sms(escalation_user)
    #SMS送信
    Rails.logger.info("SMS送信")
    begin
      sms = @client.account.messages.create({
        :from => @twilio_setting.twilio_phone_number,
        :to => escalation_user.phone_number,
        :body => "#{root_url}/#{issue.id}"})
        Rails.logger.info(sms.inspect)
    rescue Twilio::REST::RequestError => e
      Rails.logger.info("Twilio Request Error Message:#{e.backtrace.join("\n")}")
      save_issue_and_journal(issue, "Twilio Request Error Message::#{e.message}")   
    end
    sleep(WAITE_DELAY_TIME)
    sms_result = @client.account.messages.get(sms.sid)
    Rails.logger.info(sms.inspect)
    Rails.logger.info(sms_result.status
  end
  
  # 通話ステータスチェック
  def get_call_result(instance)
    # Status Check
    return @client.account.calls.get(instance.sid)
  end

  # 時刻変換
  def convert_time(time_str)
    return Time.parse(time_str).in_time_zone("Asia/Tokyo").strftime('%Y年%m月%d日 %H:%M:%S')
  end

  # チケット更新＋履歴登録
  def save_issue_and_journal(issue, notes)
    # 履歴生成
    journal = Journal.new(:journalized => issue,
        :journalized_id => issue.id,
        :notes => notes,
        :user_id => User.current.id )
    Issue.transaction do
      # チケットはupdated_atのみ更新
      issue.touch
      if !issue.save or !journal.save then
        raise ActiveRecord::Rollback
      end
    end
  end
  
  # 履歴文言生成
  def make_notes(escalation_user, result)
    notes = ''
    case result.status
    when 'completed'
      notes = "#{@count}回目の発信で#{escalation_user.name}が電話を取りました。\
               (#{convert_time(result.start_time)})"
    when 'failed'
      notes = "#{escalation_user.name}に通話を試みましが失敗しました。\
               電話番号が正しいか確認をしてください"
    else
      notes = "#{@escalation_users.size}人に#{@contu}回の発信を行いましたが、\
               誰も電話を取ることができませんでした。再度電話を試みてください。"
    end
    return notes
  end

end
