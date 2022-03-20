module Role
  class RequestService
    URL = "https://egrul.nalog.ru"
    MAX_RETRY_COUNT = 10

    class InvalidArgumentError < StandardError; end
    class RequestTokenError < StandardError; end
    class ResultTokenError < StandardError; end
    class EmptyResultRequestError < StandardError; end
    class ResultRequestError < StandardError; end
    class ResultStatusTimeoutError < StandardError; end
    class ResultFileError < StandardError; end

    def initialize(query, debug: false, request: ::Typhoeus)
      @query = query
      @debug = debug
      @request = request
    end

    def call
      raise InvalidArgumentError.new(@query) unless query_valid?

      request_token = get_request_token
      raise RequestTokenError.new(@query) unless request_token

      result_token = get_result_token(request_token)
      raise ResultTokenError.new(@query) unless result_token

      result_token = get_result_request(result_token)
      raise ResultRequestError.new(@query) unless result_token

      unless result_status_ready?(result_token)
        raise ResultStatusTimeoutError.new(@query)
      end

      result_file = get_result_file(result_token)

      raise ResultFileError.new unless result_file

      return result_file
    end

    private

    def query_valid?
      true
      # @query&.company_inn? || @query&.person_inn? || @query&.ogrn? || @query&.ogrnip?
    end

    def result_status_ready?(token, retry_count = 0)
      return true if get_result_status(token) == "ready"

      retry_count += 1
      timeout = interval(retry_count)
      sleep(timeout)

      return false if retry_count >= MAX_RETRY_COUNT

      result_status_ready?(token, retry_count)
    end

    def get_request_token
      response = @request.post(URL, body: { query: @query })
      parse(response).dig(:t) if response.success?
    end

    def get_result_token(token)
      response = @request.get("#{URL}/search-result/#{token}")
      return unless response.success?
      parsed_response = parse(response)

      raise EmptyResultRequestError.new if parsed_response.dig(:rows)&.empty?

      parsed_response.dig(:rows, 0, :t)
    end

    def get_result_request(token)
      response = @request.get("#{URL}/vyp-request/#{token}")
      parse(response).dig(:t) if response.success?
    end

    def get_result_status(token)
      response = @request.get("#{URL}/vyp-status/#{token}")
      parse(response).dig(:status) if response.success?
    end

    def get_result_file(token)
      response = @request.get("#{URL}/vyp-download/#{token}")
      return unless response.success?

      body = response.response_body
      name = "#{extract_filename(response)}.pdf"

      OpenStruct.new(body: body, name: name)
    end

    def parse(response)
      ::Oj.load(response.response_body, symbol_keys: true)
    rescue ::Oj::ParseError => e
      {}
    ensure
      output(response.response_body)
    end

    def extract_filename(response)
      response.headers["content-disposition"][/filename=(.*?).pdf/m, 1]
    end

    def output(*messages)
      @debug && print("* * *\n#{messages.join("; ")}\n* * *\n")
    end

    def interval(n)
      n < 2 || n > 20 ? n : interval(n - 1) + interval(n - 2)
    end
  end
end
