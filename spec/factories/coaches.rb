FactoryBot.define do
  factory :coach do
    firstname
    lastname
    email
    password { "Password123!" }
    password_confirmation { "Password123!" }
    zoom_account_id { "account-id" }
    zoom_client_id { "client-id" }
    zoom_client_secret { "client-secret" }
  end
end
