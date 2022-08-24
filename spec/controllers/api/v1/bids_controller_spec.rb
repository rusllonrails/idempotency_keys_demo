require 'rails_helper'
require 'support/controller_json_response'

RSpec.describe ::Api::V1::BidsController do
  include ControllerJSONResponse

  let(:idempotency_key) { 'testkey' }
  let(:amount) { 10 }

  describe 'POST #create' do
    let(:do_request) do
      request.headers['Idempotency-Key'] = idempotency_key
      post(:create, params: {amount: amount}, format: :json)
    end

    context 'when idempotency key does not exist in DB' do
      it 'creates new record and returns sum of bids' do
        do_request

        expect_status_to_be_ok
        expect(json_response).to eq(sum_of_bids: 10)
      end

      context 'when there are already some bids in DB' do
        before do
          create(:bid, amount: 5)
          create(:bid, amount: 2)
        end

        it 'creates new record and returns sum of bids (including previously created records)' do
          do_request

          expect_status_to_be_ok
          expect(json_response).to eq(sum_of_bids: 17)
        end
      end

      shared_examples 'raises RecordInvalid error when amount has wrong value' do
        specify do
          expect {
            do_request
          }.to raise_error(ActiveRecord::RecordInvalid, /Amount is not a number/)
        end
      end

      context 'when amount is blank' do
        let(:amount) { nil }

        it_behaves_like 'raises RecordInvalid error when amount has wrong value'
      end

      context 'when amount is not valid' do
        let(:amount) { 'foobar' }

        it_behaves_like 'raises RecordInvalid error when amount has wrong value'
      end

      context 'when attempt to save duplicated idempotency_key' do
        before do
          create(:idempotent_action, idempotency_key: idempotency_key)

          # Imitation that initial check in controller level passed
          allow(IdempotentAction).to receive(:exists?).with(idempotency_key: idempotency_key)
                                                      .and_return(false)
        end

        specify do
          expect {
            do_request
          }.to raise_error(ActiveRecord::RecordInvalid, /Idempotency key has already been taken/)
        end

        context 'when even passed validations' do
          before do
            # Imitation new instance of IdempotentAction passed validation
            allow_any_instance_of(IdempotentAction).to receive(:valid?).and_return(true)
          end

          specify do
            expect {
              do_request
            }.to raise_error(ActiveRecord::RecordNotUnique,
                            /Duplicate entry '#{idempotency_key}' for key 'index_idempotent_actions_on_idempotency_key'/)
          end
        end
      end
    end

    context 'when idempotency key already exist in DB' do
      before do
        create(:idempotent_action, idempotency_key: idempotency_key)
      end

      it 'does not create new record and returns sum of bids' do
        do_request

        expect_status_to_be_ok
        expect(json_response).to eq(sum_of_bids: 0)
      end

      context 'when there are already some bids in DB' do
        before do
          create(:bid, amount: 5)
          create(:bid, amount: 2)
        end

        it 'does not create new record and returns sum of bids (including previously created records)' do
          do_request

          expect_status_to_be_ok
          expect(json_response).to eq(sum_of_bids: 7)
        end
      end
    end

    context 'when Idempotency-Key is missing in headers' do
      let(:do_request) do
        request.headers['Idempotency-Key'] = nil
        post(:create, params: {amount: amount}, format: :json)
      end

      specify do
        do_request

        expect(response).to have_http_status(:bad_request)
        expect(json_response).to eq(error: 'Missing Idempotency Key')
      end
    end
  end

  private

  def expect_status_to_be_ok
    expect(response.status).to eq(200)
  end
end
