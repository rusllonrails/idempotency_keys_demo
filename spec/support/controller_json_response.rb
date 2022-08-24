# frozen_string_literal: true

# Abstracts a helper methods for inspecting a JSON
module ControllerJSONResponse
  # Parses the response body and converts `String` keys to `Symbol`s
  # @return [Hash<Symbol, Object>]
  def json_response
    Oj.load(response.body, symbol_keys: true)
  end
end

RSpec.configuration.public_send :include, ControllerJSONResponse, type: :controller
