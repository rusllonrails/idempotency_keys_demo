require 'rails_helper'
require 'support/controller_json_response'

RSpec.describe ::Api::V1::BidsController do
  include ControllerJSONResponse

  let(:idempotency_key) { 'testkey' }
  let(:amount) { 10 }

  describe 'POST #create' do
    context 'when idempotency key does not exist in DB' do
      let(:do_request) do
        request.headers['Idempotency-Key'] = idempotency_key
        post(:create, params: {amount: amount}, format: :json)
      end

      specify do
        do_request

        expect_status_to_be_ok
        expect(json_response).to eq(sum_of_bids: 10)
      end

      context 'when there are already some bids in DB' do
        before do
          create(:bid, amount: 5)
          create(:bid, amount: 2)
        end

        specify do
          do_request

          expect_status_to_be_ok
          expect(json_response).to eq(sum_of_bids: 17)
        end
      end
    end

    context 'when idempotency key already exist in DB' do
      let(:do_request) do
        request.headers['Idempotency-Key'] = idempotency_key
        post(:create, params: {amount: amount}, format: :json)
      end

      before do
        create(:idempotent_action, idempotency_key: idempotency_key)
      end

      specify do
        do_request

        expect_status_to_be_ok
        expect(json_response).to eq(sum_of_bids: 0)
      end

      context 'when there are already some bids in DB' do
        before do
          create(:bid, amount: 5)
          create(:bid, amount: 2)
        end

        specify do
          do_request

          expect_status_to_be_ok
          expect(json_response).to eq(sum_of_bids: 7)
        end
      end
    end
  end

  private

  def expect_status_to_be_ok
    expect(response.status).to eq(200)
  end
end
