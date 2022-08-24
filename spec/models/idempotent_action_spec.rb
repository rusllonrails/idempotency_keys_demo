require 'rails_helper'

RSpec.describe IdempotentAction, type: :model do
  subject(:idempotent_action) { described_class.new }

  describe 'validations' do
    specify do
      expect(idempotent_action).to validate_presence_of(:idempotency_key)
    end
  end
end
