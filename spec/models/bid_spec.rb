require 'rails_helper'

RSpec.describe Bid, type: :model do
  subject(:bid) { described_class.new }

  describe 'validations' do
    specify do
      expect(bid).to validate_numericality_of(:amount)
    end
  end
end
