module Helpers
  module Request
    def json_pagination
      json_body[:pagination]
    end

    def json_data
      json_body[:data]
    end

    def json_errors
      json_body[:errors]
    end

    def json_body
      Oj.load(response.body, symbol_keys: true)
    end
  end
end
