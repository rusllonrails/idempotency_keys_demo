class IdempotentAction < ApplicationRecord
  validates :idempotency_key, presence: true, uniqueness: true
end
