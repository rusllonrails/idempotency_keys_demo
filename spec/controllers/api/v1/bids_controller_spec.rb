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

    shared_examples 'creates new record (if needed) and returns sum' do |sum_of_bids, sum_of_bids_when_existing_records|
      specify do
        do_request

        expect_status_to_be_ok
        expect(json_response).to eq(sum_of_bids: sum_of_bids)
      end

      context 'when there are already some bids in DB' do
        before do
          create(:bid, amount: 5)
          create(:bid, amount: 2)
        end

        specify do
          do_request

          expect_status_to_be_ok
          expect(json_response).to eq(sum_of_bids: sum_of_bids_when_existing_records)
        end
      end
    end

    context 'when idempotency key does not exist in DB' do
      it_behaves_like 'creates new record (if needed) and returns sum', 10, 17

      shared_examples 'raises RecordInvalid error when amount has wrong value' do
        specify do
          expect {
            do_request
          }.to raise_error(ActiveRecord::RecordInvalid)
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
    end

    context 'when idempotency key already exist in DB' do
      before do
        create(:idempotent_action, idempotency_key: idempotency_key)
      end

      it_behaves_like 'creates new record (if needed) and returns sum', 0, 7
    end
  end

  private

  def expect_status_to_be_ok
    expect(response.status).to eq(200)
  end
end



        # specify do
        #   expect {
        #     do_request
        #   }.to raise_error(ActiveRecord::RecordInvalid)

          # puts ""
          # puts "-" * 50
          # puts ""
          # puts "response.status: #{response.status}"
          # puts "json_response: #{json_response}"
          # puts ""
          # puts "-" * 50
          # puts ""

          # expect_status_to_be_ok
          # expect(json_response).to eq(sum_of_bids: 0)
        # end
