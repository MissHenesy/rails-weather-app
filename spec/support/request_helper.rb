require_relative '../../config/environment'
require 'spec_helper'
require 'rack/test'
require 'faraday'
require 'json'

def app
  # Rack::Builder.parse_file('config.ru').first
  Rails.application
end

def response
  last_response
end

RSpec.configure do |c|
  c.include Rack::Test::Methods
end
