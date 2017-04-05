resources :calls, :only => [:create]
resources :calls, :only => [:show], :to => 'issues#show'
get 'calls', :to => 'issues#show'

resources :escalation_users
#get 'escalation_users', :to => 'escalation_users#index'
