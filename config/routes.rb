Rails.application.routes.draw do
  root "recipes#index"
  resources :recipes, only: %i[index show] do
    get :audio, on: :member
  end
  post "voice_assistant", to: "recipes#voice_assistant"
end
