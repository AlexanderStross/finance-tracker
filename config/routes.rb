Rails.application.routes.draw do
  resources :user_stocks, only: %i[create destroy]
  devise_for :users
  root 'welcome#index'
  get 'my_portfolio', to: 'users#my_portfolio'
  get 'search_stock', to: 'stocks#search'
  get 'update_prices_now', to: 'stocks#update_prices_now'
  get 'friends', to: 'users#friends'
  get 'search_friend', to: 'users#search'
  get 'refresh_table', to: 'users#refresh_table', remote: true
  resources :friendships, only: %i[create destroy]
  resources :users, only: [:show]
end
