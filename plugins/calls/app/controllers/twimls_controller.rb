class TwimlsController < ApplicationController
  
  def index
    resp = nil
    
    if params[:Digits]
      case params[:Digits]
      when '1'
        Rails.logger.info "Dial Push = 1"
      when '2'
        Rails.logger.info "Dial Push = 2"
      end
      resp = Twilio::TwiML::Response.new do |r|
        r.Say '1または2を押してください', voice: 'alice', language: 'it-IT'
        r.Hangup
      end
    else
      resp = Twilio::TwiML::Response.new do |r|
        r.Gather timeout: 10, numDigits: 1 do |g|
          g.Say "This is Waker alert.", voice: 'alice', language: 'en-US'
          g.Say "To acknowledge, press 1.", voice: 'alice', language: 'en-US'
          g.Say "To resolve, press 2.", voice: 'alice', language: 'en-US'
        end
      end
    end

    render xml: resp.text
  end
end
