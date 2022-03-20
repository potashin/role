Role::Engine.routes.draw do
  resources :exports, only: %i[index create show], path: "exports/:entity_id"
end
