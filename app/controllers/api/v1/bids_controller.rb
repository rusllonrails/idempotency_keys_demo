module Api
  module V1
    class BidsController < ::ApplicationController
      include IdempotentRequestHelper

      MISSING_IDEMPOTENCY_KEY = 'Missing Idempotency Key'.freeze

      def create
        bad_request_response and return if idempotency_key.blank?
        success_response and return if idempotent_redis_service.equivalent_request?

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
          idempotent_redis_service.track_idempotency_key!

          Bid.create!(amount: params[:amount])
          IdempotentAction.create!(idempotency_key: idempotency_key)
        ensure
          idempotent_redis_service.clean_up_idempotency_key!
        end
      end

      def success_response
        render json: {
          sum_of_bids: Bid.sum(:amount)
        }.to_json
      end

      def bad_request_response
        render json: {error: MISSING_IDEMPOTENCY_KEY}, status: :bad_request
      end

      def idempotent_redis_service
        @idempotent_redis_service ||= IdempotentRedisService.new(idempotency_key)
      end
    end
  end
end
