class EscalationUsersController < ApplicationController
  unloadable
  before_action :find_escalation_user, :only => [:show, :edit, :update, :destroy]
 
  def index
    @escalation_users = EscalationUser.order(:priority)
  end
  
  def new
    @escalation_user = EscalationUser.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @escalation_user = EscalationUser.new(post_params)

    respond_to do |format|
      if @escalation_user.save
        format.html { redirect_to plugin_settings_path(id: 'calls'), notice: 'Friend was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @escalation_user.update(post_params)
        format.html { redirect_to plugin_settings_path(id: 'calls'), notice: 'Friend was successfully created.' } 
      else
        format.html { render :action => :edit }
      end
    end
  end
 
  def destroy
    @escalation_user.destroy
    respond_to do |format|
      format.html { redirect_back_or_default(plugin_settings_path(id: 'calls')) }
    end
  end

private

  def post_params
    params.require(:escalation_user).permit(
      :name, :phone_number, :priority
    )
  end

  def find_escalation_user
    @escalation_user = EscalationUser.find(params[:id])
  end

end
