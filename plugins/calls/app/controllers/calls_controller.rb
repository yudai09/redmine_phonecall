class CallsController < ApplicationController
  unloadable
  before_action :find_issue, :only => [:create] 

  def create
    Rails.logger.info(params.inspect)
    Rails.logger.info(@issue.inspect)
    Rails.logger.info(User.current.inspect)
    
    call = Call.new(:issue_id => @issue.id)

    # 電話を発信
    result = false
    begin
      result = call.calling(@issue)
    rescue ActiveRecord::StaleObjectError
      @conflict = true
    end

    if result
      Rails.logger.info('Success calling')
      redirect_to :controller => 'issues', :action => 'show', :id => @issue.id
      #respond_to do |format|
      #  format.html { render :controller => 'issues', :action => 'show', :id => @issue.id }
      #  format.api  { render_api_ok }
      #end
    else
      Rails.logger.info('Error calling')
      respond_to do |format|
        format.html { render :controller => 'issues', :action => 'edit', :id => @issue.id }
        format.api  { render_validation_errors(@issue) }
      end
    end
  end
end
