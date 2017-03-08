#
# lib/issues_controller_patch.rb
#
require_dependency 'issues_controller'

module IssuesControllerPatch

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      accept_rss_auth :calling
      accept_api_auth :calling
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def calling
      Rails.logger.info('issues_controller calling!!!')
      redirect_to 'show'
    end
  end
end

#IssuesController.send(:include, IssuesControllerPatch)
