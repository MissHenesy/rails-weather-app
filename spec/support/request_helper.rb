require_relative '../../config/environment'
require 'spec_helper'
require 'rack/test'
require 'faraday'
require 'json'
require 'ostruct'

def app
  # Rack::Builder.parse_file('config.ru').first
  Rails.application
end

def response
  last_response
end

def create_stub(stub_url, stub_code, stub_body)
  stub_request(:get, stub_url).
    with(headers: { 'Accept'=>'*/*', 'User-Agent'=>"Faraday v#{Faraday::VERSION}" }).
    to_return(status: stub_code, body: stub_body)
  
  uri = URI(stub_url)
  Faraday.get(uri)
end

RSpec.configure do |c|
  c.include Rack::Test::Methods
end
