Rails.application.routes.draw do
  root "recipes#index"
  resources :recipes, only: %i[index show]
  post "recipes/:id/audio", to: "recipes#audio", as: :recipe_audio
  post "voice_assistant", to: "recipes#voice_assistant"
end
