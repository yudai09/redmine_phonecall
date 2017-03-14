resources :calls, :only => [:create]
resources :calls, :only => [:show], :to => 'issues#show'
get 'calls', :to => 'issues#show'
