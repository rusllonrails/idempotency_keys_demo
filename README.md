# README

Simple Rails API application, which demonstrates using of Idempotency-Keys.

App has one endpoint: http://localhost:3000/api/v1/bids
Endpoint is expecting `Idempotency-Key` header and `amount` params (as Integer).

# How to run app

```
bundle
rake db:create db:migrate
rails s
```

# How to make a call to API via CURL

```
curl -X POST -H "Content-Type: application/json" -H "Idempotency-Key: AGJ6FJMkGQIpHUTX" -d '{"amount": 10}' http://localhost:3000/api/v1/bids
```

# How to run tests


```
RAILS_ENV=test bundle exec rspec spec
```
