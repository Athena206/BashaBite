Rails.application.routes.draw do
  root "recipes#index"
  resources :recipes, only: %i[index show]
  post "voice_assistant", to: "recipes#voice_assistant"
end
