FactoryBot.define do
  factory :idempotent_action do
    idempotency_key { SecureRandom.uuid }
  end
end
