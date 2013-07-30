Store::Application.routes.draw do
  resources :users do
    post 'filter_panel', :on => :collection
    get 'show_info_table', :on => :member
    get 'show_sells', :on => :member
    get 'show_bought', :on => :member
    get 'show_sold', :on => :member
    post 'select_table', :on => :member
  end
  resources :lists do
    post 'filter_panel', :on => :collection
  end
  root to: 'lists#index'
end
