resources :expo_push_tokens, only: %i(create) 
delete "expo_push_tokens", to: "expo_push_tokens#destroy_all"
