require 'rails_helper'

describe(RequestService, type: :service) do
  let(:query) { '772002950380' }
  let(:url) { described_class::URL }

  let(:request_token) { '1' }
  let(:request_token_fixture) { {t: request_token}.to_json }

  let(:result_token) { '2' }
  let(:result_token_fixture) { {rows: [{t: result_token}]}.to_json }

  let(:empty_result_token_fixture) { {rows: []}.to_json }
  let(:result_request_fixture) { {t: result_token}.to_json }
  let(:result_status_waiting_fixture) { {status: :waiting}.to_json }
  let(:result_status_ready_fixture) { {status: :ready}.to_json }
  let(:result_file_fixture) { file_fixture('sample.pdf').read }

  let(:result_file_name) { 'fl-304770000131449-20200330220403.pdf' }
  let(:result_file_headers) {
 {'content-disposition' => "attachment; filename=#{result_file_name}"} }

  it 'should raise RequestTokenError exception' do
    stub_request(:post, url).with(body: "query=#{query}").to_return(status: 500)

    expect {
      described_class.new(query).call
    }.to(raise_error(described_class::RequestTokenError))
  end

  it 'should raise ResultTokenError exception' do
    stub_request(:post, url).with(body: "query=#{query}").to_return(
      status: 200,
      body: request_token_fixture
    )
    stub_request(:get, "#{url}/search-result/#{request_token}").to_return(status: 500)

    expect {
      described_class.new(query).call
    }.to(raise_error(described_class::ResultTokenError))
  end

  it 'should raise EmptyResultRequestError exception' do
    stub_request(:post, url).with(body: "query=#{query}").to_return(
      status: 200,
      body: request_token_fixture
    )
    stub_request(:get, "#{url}/search-result/#{request_token}").to_return(
      status: 200,
      body: empty_result_token_fixture
    )

    expect {
      described_class.new(query).call
    }.to(raise_error(described_class::EmptyResultRequestError))
  end

  it 'should raise ResultRequestError exception' do
    stub_request(:post, url).with(body: "query=#{query}").to_return(
      status: 200,
      body: request_token_fixture
    )
    stub_request(:get, "#{url}/search-result/#{request_token}").to_return(
      status: 200,
      body: result_token_fixture
    )
    stub_request(:get, "#{url}/vyp-request/#{result_token}").to_return(status: 500)

    expect {
      described_class.new(query).call
    }.to(raise_error(described_class::ResultRequestError))
  end

  it 'should raise ResultStatusTimeoutError exception' do
    stub_request(:post, url).with(body: "query=#{query}").to_return(
      status: 200,
      body: request_token_fixture
    )
    stub_request(:get, "#{url}/search-result/#{request_token}").to_return(
      status: 200,
      body: result_token_fixture
    )
    stub_request(:get, "#{url}/vyp-request/#{result_token}").to_return(
      status: 200,
      body: result_request_fixture
    )
    stub_request(:get, "#{url}/vyp-status/#{result_token}").to_return(
      status: 200,
      body: result_status_waiting_fixture
    )

    allow_any_instance_of(described_class).to(receive(:sleep))

    expect {
      described_class.new(query).call
    }.to(raise_error(described_class::ResultStatusTimeoutError))
  end

  it 'should raise ResultFileError exception' do
    stub_request(:post, url).with(body: "query=#{query}").to_return(
      status: 200,
      body: request_token_fixture
    )
    stub_request(:get, "#{url}/search-result/#{request_token}").to_return(
      status: 200,
      body: result_token_fixture
    )
    stub_request(:get, "#{url}/vyp-request/#{result_token}").to_return(
      status: 200,
      body: result_request_fixture
    )
    stub_request(:get, "#{url}/vyp-status/#{result_token}").to_return(
      status: 200,
      body: result_status_ready_fixture
    )
    stub_request(:get, "#{url}/vyp-download/#{result_token}").to_return(status: 500)

    expect {
      described_class.new(query).call
    }.to(raise_error(described_class::ResultFileError))
  end

  it 'should not raise any errors' do
    stub_request(:post, url).with(body: "query=#{query}").to_return(
      status: 200,
      body: request_token_fixture
    )
    stub_request(:get, "#{url}/search-result/#{request_token}").to_return(
      status: 200,
      body: result_token_fixture
    )
    stub_request(:get, "#{url}/vyp-request/#{result_token}").to_return(
      status: 200,
      body: result_request_fixture
    )
    stub_request(:get, "#{url}/vyp-status/#{result_token}").to_return(
      status: 200,
      body: result_status_ready_fixture
    )
    stub_request(:get, "#{url}/vyp-download/#{result_token}").to_return(
      status: 200,
      body: result_file_fixture,
      headers: result_file_headers
    )

    file = described_class.new(query).call

    expect(file.name).to(eq(result_file_name))
    expect(file.body).to(eq(result_file_fixture))
  end
end
