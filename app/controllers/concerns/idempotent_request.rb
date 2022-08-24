module IdempotentRequest
  IDEMPOTENCY_HEADER = 'HTTP_IDEMPOTENCY_KEY'.freeze
  REDIS_NAMESPACE = 'idempotency_keys'.freeze
  REDIS_EXPIRE_TIME = 1.day.to_i

  def idempotency_key
    @idempotency_key ||= request.headers[IDEMPOTENCY_HEADER]
  end

  def equivalent_request?
    redis.get(redis_key)
  end

  def track_idempotency_key!
    redis.set(redis_key, 'tracked')
    redis.expire(redis_key, REDIS_EXPIRE_TIME)
  end

  def clean_up_idempotency_key!
    redis.del(redis_key)
  end

  def redis_key
    @redis_key ||= "#{REDIS_NAMESPACE}:#{idempotency_key}"
  end

  def redis
    @redis ||= ::Redis.current
  end
end
