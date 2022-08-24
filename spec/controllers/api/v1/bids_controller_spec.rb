require 'rails_helper'
require 'support/controller_json_response'

RSpec.describe ::Api::V1::BidsController do
  include ControllerJSONResponse

  let(:idempotency_key) { 'testkey' }
  let(:amount) { 10 }

  describe 'POST #create' do
    context 'when idempotency key does not exist in DB' do
      it 'creates saves new big in DB and renders success response' do
        request.headers['Idempotency-Key'] = idempotency_key
        post(:create, params: {amount: amount}, format: :json)

        expect(response.status).to eq(200)
        expect(json_response).to eq(sum_of_bids: 10)
      end
    end
  end
end
