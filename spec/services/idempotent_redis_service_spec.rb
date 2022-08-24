require 'rails_helper'

RSpec.describe IdempotentRedisService do
  subject(:service) { described_class.new(idempotency_key) }

  let(:idempotency_key) { 'testkey' }
  let(:redis_key) { "idempotency_keys:#{idempotency_key}" }

  before do
    $redis.set(redis_key, 'tracked')
  end

  describe '#equivalent_request?' do
    context 'when idempotency key was tracked in Redis' do
      specify do
        expect(service.equivalent_request?).to be_truthy
      end
    end

    context 'when idempotency key was not tracked in Redis yet' do
      before { service.clean_up_idempotency_key! }

      specify do
        expect(service.equivalent_request?).to be_falsey
      end
    end
  end

  describe '#track_idempotency_key!' do
    before { service.clean_up_idempotency_key! }

    specify do
      expect($redis).to receive(:expire).with(redis_key, described_class::REDIS_EXPIRE_TIME)

      expect {
        service.track_idempotency_key!
      }.to change(service, :equivalent_request?).from(false).to(true)
    end
  end

  describe '#clean_up_idempotency_key!' do
    specify do
      expect {
        service.clean_up_idempotency_key!
      }.to change(service, :equivalent_request?).from(true).to(false)
    end
  end
end
