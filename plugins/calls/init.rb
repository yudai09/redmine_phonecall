#require_dependency 'calls_hook_listener'
#パッチ
#require_dependency 'issues_controller_patch'
#IssuesController.send(:include, IssuesControllerPatch)
#フック
#require 'calls/hooks/controller_issues_edit_before_save_hook'
Redmine::Plugin.register :calls do
  name 'Calls plugin'
  author 'nifty'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  # menu :application_menu, :calls, { :controller => 'calls', :action => 'index' }, :caption => 'Calls'
end
