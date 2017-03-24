class CallsController < ApplicationController
  unloadable
  before_action :find_issue, :only => [:create] 

  def create
    saved = false
    # エスカレーション開始履歴登録
    begin
      saved = save_start_escalation_info
      if saved
        pid = fork do
          caller = Call.new(:issue_id => @issue.id)
          caller.call(@issue, url_for(:controller => 'issues')) 
        end
        Process.detach(pid) #子プロセスは独立
      end
    rescue ActiveRecord::StaleObjectError
      @conflict = true
    end

    if saved
      redirect_to :controller => 'issues', :action => 'show', :id => @issue.id
    else
      respond_to do |format|
        format.html { render :controller => 'issues', :action => 'edit', :id => @issue.id }
        format.api  { render_validation_errors(@issue) }
      end
    end
  end
  
  private
  
  def save_start_escalation_info
    journal = Journal.new(:journalized => @issue,
                          :journalized_id => @issue.id,
                          :notes => "エスカレーションを開始しました。\
                                     (#{Time.now.to_time.strftime('%Y年%m月%d日 %H:%M:%S')})",
                          :user_id => User.current.id )
    Issue.transaction do
      @issue.touch
      if !@issue.save or !journal.save
        raise ActiveRecord::Rollback
        return false
      end
    end
    return true
  end

end
