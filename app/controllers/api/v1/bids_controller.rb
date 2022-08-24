module Api
  module V1
    class BidsController < ::ApplicationController
      IDEMPOTENCY_HEADER = 'HTTP_IDEMPOTENCY_KEY'.freeze

      def create
        if IdempotentAction.exists?(idempotency_key: idempotency_key)
          success_response
        else
          persist_bid!
          success_response
        end
      end

      private

      def persist_bid!
        ActiveRecord::Base.transaction do
          Bid.create!(amount: params[:amount])
          IdempotentAction.create!(idempotency_key: idempotency_key)
        end
      end

      def success_response
        render json: {
          sum_of_bids: Bid.sum(:amount)
        }.to_json
      end

      def idempotency_key
        @idempotency_key ||= request.headers[IDEMPOTENCY_HEADER]
      end
    end
  end
end
