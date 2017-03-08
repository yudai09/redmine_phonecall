require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'

class EscalationOperateService
  unloadable

  def initialize(escalation_users, escalation_rules)
    @escalation_users = escalation_users
    @escalation_rules = escalation_rules
  end

  def escalate
    @escalation_rules.each do |escalation_rule|
      Rails.logger.info(escalation_rule.inspect)

      @escalation_users.each do |escalation_user|
        Rails.logger.info(escalation_user.inspect)
        
        account_sid = 'AC6053f63bba9aa833348c3e1a4cb9054e'
        auth_token = '9ea5d8edd2196e7a91af542100713494'
        
        # set up a client to talk to the Twilio REST API
        @client = Twilio::REST::Client.new account_sid, auth_token
        
        # calling
        call = @client.account.calls.create({
          :url => 'http://demo.twilio.com/docs/voice.xml', 
          :to => escalation_user.phone_number.sub(/^0/, '+81'),
          :from => '+815031878993',
          :timeout => escalation_rule.timeout
        })
        
        sleep(escalation_rule.timeout + 5)

        Rails.logger.info(call.inspect)
        Rails.logger.info(call.status)
         

      end

    end

  end
end
