module Calls
  class Hooks < Redmine::Hook::ViewListener
    def controller_issues_edit_before_save(context={})
      Rails.logger.info('controller_issues_edit_before_save calling!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    end
  end
end
