module IdempotentRequestHelper
  IDEMPOTENCY_HEADER = 'HTTP_IDEMPOTENCY_KEY'.freeze

  def idempotency_key
    @idempotency_key ||= request.headers[IDEMPOTENCY_HEADER]
  end
end
