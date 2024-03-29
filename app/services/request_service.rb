class RequestService
  URL = 'https://egrul.nalog.ru'.freeze

  class InvalidArgumentError < Exceptions::Base; end
  class RequestTokenError < Exceptions::Base; end
  class ResultTokenError < Exceptions::Base; end
  class EmptyResultRequestError < Exceptions::Base; end
  class ResultRequestError < Exceptions::Base; end
  class ResultStatusTimeoutError < Exceptions::Base; end
  class ResultFileError < Exceptions::Base; end

  def initialize(query, debug: false, request: ::Typhoeus)
    @query = query
    @debug = debug
    @request = request
  end

  def call
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

    result_file
  end

  private

  def result_status_ready?(token)
    get_result_status(token) == 'ready'
  end

  def get_request_token
    response = @request.post(URL, body: {query: @query})
    parse(response).dig(:t) if response.success?
  end

  def get_result_token(token)
    response = @request.get("#{URL}/search-result/#{token}", **timeouts)
    return unless response.success?
    parsed_response = parse(response)

    raise EmptyResultRequestError.new if parsed_response.dig(:rows)&.empty?

    parsed_response.dig(:rows, 0, :t)
  end

  def get_result_request(token)
    response = @request.get("#{URL}/vyp-request/#{token}", **timeouts)
    parse(response).dig(:t) if response.success?
  end

  def get_result_status(token)
    response = @request.get("#{URL}/vyp-status/#{token}", **timeouts)
    parse(response).dig(:status) if response.success?
  end

  def get_result_file(token)
    response = @request.get("#{URL}/vyp-download/#{token}", **timeouts)
    return unless response.success?

    body = response.response_body
    name = "#{extract_filename(response)}.pdf"

    OpenStruct.new(body:, name:)
  end

  def parse(response)
    ::Oj.load(response.response_body, symbol_keys: true)
  rescue ::Oj::ParseError => e
    {}
  ensure
    output(response.response_body)
  end

  def timeouts
    {
      timeout: 10,
      connecttimeout: 1,
    }
  end

  def extract_filename(response)
    response.headers['content-disposition'][/filename=(.*?).pdf/m, 1]
  end

  def output(*messages)
    @debug && print("* * *\n#{messages.join("; ")}\n* * *\n")
  end
end
