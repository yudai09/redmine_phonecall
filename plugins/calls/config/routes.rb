# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

#post 'post/:id/calling', :to => 'calls#calling'
#post 'issues/:id/calling', :to => 'calls#calling'
#post 'issues/:id/calling', :to => 'issues#show'

#resources :calls, :only => [:create], :path => 'issues', :path_names => {:create => 'calling'}

resources :calls, :only => [:create]
resources :calls, :only => [:show], :to => 'issues#show'
get 'calls', :to => 'issues#show'

#resources :calls, :only => [:show], :to => 'issues#show'

#resources :issues do
#  member do
#    post 'call', :to => 'calls#create'
#    #post 'call', :to => 'issues#create'
#    #get 'call', :to => 'issues#show'
#  end
#end

#get 'twimls/index'
#resources :twimls
#resources :twimls do
#  member do
#    get 'twiml'
#  end
#end
