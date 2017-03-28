class EscalationUser < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes
end
