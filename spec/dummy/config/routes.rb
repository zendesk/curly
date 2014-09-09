Rails.application.routes.draw do
  root to: "dashboards#show"
  get "/partials", to: "dashboards#partials"
end
