Ratemyplace::Application.routes.draw do
  resources :contacts

  resources :uploads

  resources :tags

  resources :sessions

  resources :users

  resources :councils
    
  resources :inspections do
	  collection do
	    match 'search.json' => 'inspections#searchapi', :format=>false, :defaults=>{:format=>'json'}
	    match 'search.xml' => 'inspections#searchapi', :format=>false, :defaults=>{:format=>'xml'}
	    match 'search' => 'inspections#search', :via => [:get, :post], :as => :search
	    match 'a-z' => 'inspections#atoz', :via => [:get], :as => :atoz
	    match 'a-z/:council/:letter' => 'inspections#atoz', :via => [:get], :as => :atoz
	    match ':id/rejectappeal' => 'inspections#rejectappeal', :via => [:get], :as => :rejectappeal
	    match 'fsa/:council.xml' => 'inspections#fsa', :format => false, :defaults=>{:format=>'xml'}
	  end
  end
      
  # Admin stuff
  
  match 'admin' => 'inspections#admin', :as => :admin
  match 'admin/new' => 'inspections#new', :as => :new
  match 'admin/editsearch' => 'inspections#editsearch', :as => :editsearch
  match 'admin/certificatesearch' => 'inspections#certificatesearch', :as => :certificatesearch
  match 'admin/edit/:id' => 'inspections#edit', :as => :edit
  match 'admin/certificate/:id' => 'inspections#certificate', :as => :certificate
  match 'admin/profile' => 'users#edit', :as => :edit_current_user
  match 'admin/newuser' => 'users#new', :as => :signup
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login
  
  # Address 
    
  match 'address/postcode/:postcode' => 'address#postcode'
  match 'address/uprn/:uprn' => 'address#uprn'
  
  # Nearest
  
  match 'nearest' => 'inspections#nearest', :as => :nearest
  
  # Contact stuff
  
  match 'contact-us' => 'contacts#new'
  
  # Legacy redirects
  
  match 'view/:id/:name' => 'inspections#redirect',  :defaults=>{:format=>'html'}
  match 'widget.php' => 'inspections#redirect',  :defaults=>{:format=>'js'}

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'
  root :to => 'inspections#index'

  # See how all your routes lay out with "rake routes"
  
  match ':action' => 'static#:action'
end
