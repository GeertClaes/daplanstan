Rails.application.routes.draw do
  # Health check — reachable on any subdomain
  get "up" => "rails/health#show", as: :rails_health_check

  # ── App ── whats.daplanstan.com ─────────────────────────────────────────────
  constraints host: /\Awhats\./ do
    root "home#app", as: :app_root

    get "/privacy", to: "home#privacy", as: :privacy
    get "/terms",   to: "home#terms",   as: :terms

    get    "/auth/:provider/callback", to: "sessions#create"
    delete "/auth/sign_out",           to: "sessions#destroy", as: :sign_out
    get    "/auth/failure",            to: "sessions#failure"

    get "/notifications", to: "notifications#index", as: :notifications

    get "/waitlist",  to: "invites#waitlist", as: :waitlist
    get "/i/:token",  to: "invites#accept",   as: :accept_invite

    resources :trips do
      member do
        post  :regenerate_inbound_email
        get   :cover
        patch :update_cover
        post  :refresh_cover
        get   :travelers
      end
      resources :trip_items do
        collection do
          get  :import
          post :import
        end
        member do
          patch :confirm
          get   :to_expense
        end
      end
      resources :trip_members, only: [ :create, :destroy ]
      resources :expenses, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
        member { patch :confirm }
      end
      resources :inbox_items, only: [ :index, :show, :update, :destroy ]
      resources :approved_senders, only: [ :create, :destroy ]
    end

    resource :settings, only: [ :show, :edit, :update ] do
      resources :travelers, only: [ :create, :update, :destroy ]
      resources :invites,   only: [ :index, :create, :destroy ]
    end
  end

  # ── Apex ── daplanstan.com → redirect to app (until www GitHub Pages is live) ─
  constraints host: "daplanstan.com" do
    root to: redirect("https://www.daplanstan.com/", status: 301), as: :apex_root
    get "*path", to: redirect(status: 301) { |_params, req| "https://www.daplanstan.com#{req.path}" }
  end
end
