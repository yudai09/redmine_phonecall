require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'

class Call < ActiveRecord::Base
  unloadable
  after_initialize :set_call_setting

  WAIT_DELAY_TIME = 10   # Twilio-API呼び出し時の待ち時間
  MAX_CALLING_COUNT = 2   # 通話結果が"発信待ち","呼び出し中","通話中"のいずれかの場合の再確認回数
  
  def call(issue, root_url)
    Rails.logger.info("Processing by Call :")
    # エスカレーション
    (1..Setting.plugin_calls['max_loop_count'].to_i).each.with_index(1) do |loop_count|
      @escalation_users.each do |escalation_user|
        Rails.logger.info("  Call Info : round=#{loop_count}, user=#{escalation_user.user.name}")
        calling_count ||= 0
        begin
          # 発信
          calling ||= to_call(escalation_user)
          Rails.logger.info("  Call Info : calling=#{calling.inspect}")
          # Wait
          sleep(Setting.plugin_calls['timeout'].to_i + WAIT_DELAY_TIME)
          # ステータス取得
          if !calling.nil?
            @call_status = @client.account.calls.get(calling.sid).status
            Rails.logger.info("  Call Info : status=#{@call_status}")
          end
        rescue Twilio::REST::RequestError => e
          Rails.logger.error("Twilio Request Error Call:#{e.backtrace.join("\n")}")
          @notes = "Twilio Request Error Call: #{e.message}, user=#{escalation_user.user.name}, phone_number=#{escalation_user.phone_number}"
          save_issue_and_journal(issue)
        end
        
        # チケット文言生成 
        @notes = make_notes(loop_count, escalation_user)
        
        case @call_status
        when 'completed'  # 通話成功
          save_issue_and_journal(issue)
          Rails.logger.info("  Call Info : Success Call")
          send_sms(escalation_user, root_url, issue)
          send_notification(issue)
          return
        when 'failed'     # 通話失敗
          save_issue_and_journal(issue)
          Rails.logger.info("  Call Info : Failed. Next User")
          next
        when 'queued','ringing','in-progress' # 通話待ち
          if calling_count < MAX_CALLING_COUNT
            calling_count+=1
            Rails.logger.info("  Call Info : Wating. Check again")
            redo # ステータス再確認
          else
            Rails.logger.info("  Call Info : Not completed. Next User ")
            next
          end
        else # 'busy,'no-answer','canceled' or other
          Rails.logger.info("  Call Info : Not connected. Next User")
          next
        end
      end
        Rails.logger.info("  Call Info : Next loop")
    end
    Rails.logger.info("  Call Info : No one answered the phone")
    save_issue_and_journal(issue)
  end

  private

  # エスカレーション設定
  def set_call_setting
    @call_status = ''
    @escalation_users = EscalationUser.order(:priority)
    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new Setting.plugin_calls['twilio_sid'], Setting.plugin_calls['twilio_token']
  end

  # Twilioで通知
  def to_call(escalation_user)
    return @client.account.calls.create({
             :url => Setting.plugin_calls['twilio_respons_url'],
             :to => escalation_user.phone_number,
             :from => Setting.plugin_calls['twilio_phone_number'],
             :timeout => Setting.plugin_calls['timeout'].to_i})
  end
  
  # SMS通知
  def send_sms(user, root_url, issue)
    #SMS送信
    Rails.logger.info("  Call Info : Send SMS")
    begin
    sms_sid_list = []
      @escalation_users.each do |escalation_user|
        send_sms = @client.account.messages.create({
          :from => Setting.plugin_calls['twilio_phone_number'],
          :to => escalation_user.phone_number,
          :body => "#{root_url}/#{issue.id} \n pick up user = #{user.user.name}"})
        Rails.logger.info("  Call Info : send_sms=#{send_sms.inspect}")
        sms_sid_list.push(send_sms.sid)
      end
      sleep(WAIT_DELAY_TIME)
      sms_sid_list.each do |sid|
         result_sms = @client.account.messages.get(sid)
         Rails.logger.info("  Call Info : result_sms to=#{result_sms.to}, status=#{result_sms.status}")
      end
    rescue Twilio::REST::RequestError => e
      Rails.logger.error("Twilio Request Error Message:#{e.backtrace.join("\n")}")
      @notes = "Twilio Request Error Message::#{e.message}, user=#{escalation_user.user.name}, phone_number=#{escalation_user.phone_number}"
      save_issue_and_journal(issue)   
    end
  end
  
  # チケット更新＋履歴登録
  def save_issue_and_journal(issue)
    # 履歴生成
    journal = Journal.new(:journalized => issue,
        :journalized_id => issue.id,
        :notes => @notes,
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
  def make_notes(loop_count, escalation_user)
    notes = ''
    case @call_status
    when 'completed'
      notes = "#{loop_count}回目の発信で#{escalation_user.user.name}が電話を取りました。"
    when 'failed'
      notes = "#{escalation_user.user.name}に通話を試みましが失敗しました。\
               電話番号が正しいか確認をしてください"
    else
      notes = "#{@escalation_users.size}人に#{loop_count}回の発信を行いましたが、\
               誰も電話を取ることができませんでした。再度電話を試みてください。"
    end
    return notes
  end

  # メール送信
  def send_notification(issue)
    to = Array.new
    @escalation_users.each do |escalation_user|
      to.push(escalation_user.user)
    end
    cc = []
    issue.each_notification(to) do |users| 
      Mailer.issue_add(issue, users, cc).deliver
    end
  end

end
