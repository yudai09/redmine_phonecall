class EscalationUsersController < ApplicationController
  unloadable

  def index
    @escalation_users = EscalationUser.all
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

private

  def post_params
    params.require(:escalation_user).permit(
      :name, :phone_number
    )
  end

end
