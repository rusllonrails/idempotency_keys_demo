module Api
  module V1
    class BidsController < ::ApplicationController
      IDEMPOTENCY_HEADER = 'HTTP_IDEMPOTENCY_KEY'.freeze
      REDIS_NAMESPACE = 'idempotency_keys'.freeze
      REDIS_EXPIRE_TIME = 1.day.to_i
      MISSING_IDEMPOTENCY_KEY = 'Missing Idempotency Key'.freeze

      def create
        bad_request_response and return if idempotency_key.blank?
        success_response and return if equivalent_request?

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
          track_idempotency_key!

          Bid.create!(amount: params[:amount])
          IdempotentAction.create!(idempotency_key: idempotency_key)
        ensure
          clean_up_idempotency_key!
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

      def idempotency_key
        @idempotency_key ||= request.headers[IDEMPOTENCY_HEADER]
      end

      def redis
        @redis ||= ::Redis.current
      end

      def redis_key
        @redis_key ||= "#{REDIS_NAMESPACE}:#{idempotency_key}"
      end

      def track_idempotency_key!
        redis.hmset(redis_key, 'tracked')
        redis.expire(redis_key, REDIS_EXPIRE_TIME)
      end

      def clean_up_idempotency_key!
        redis.del(redis_key)
      end

      def equivalent_request?
        redis.hexists(redis_key, 'tracked')
      end
    end
  end
end
