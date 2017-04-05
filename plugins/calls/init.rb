Redmine::Plugin.register :calls do
  name 'Call'
  author 'Nakano Masatoshi'
  description 'make call by twilio'
  version '0.0.1'
  settings :default => {'empty' => true}, :partial => 'settings/call_settings'
end
