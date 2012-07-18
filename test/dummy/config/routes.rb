Dummy::Application.routes.draw do
  get 'data', :to => 'data#index'
  get 'filters', :to => 'data#filters'
end
