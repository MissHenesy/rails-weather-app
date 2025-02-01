require './spec/support/request_helper'

RSpec.describe 'openweathermap requests', type: :request do
  
  let(:base_api_url) { 'https://api.openweathermap.org/data/3.0/onecall' }
  let(:latitude) { '44.279491' } 
  let(:longitude) { '-73.979871' }

  describe 'Requests data from openweathermap.com with GET' do

    it 'returns weather data when given a valid location' do
      json_data = File.read('spec/fixtures/mock_weather_data.json')
      api_response = JSON.parse(json_data)
      api_url = "#{base_api_url}?lat=#{latitude}&lon=#{longitude}"

      stub_request(:get, api_url).
        with(headers: {'Accept'=>'*/*', 'User-Agent'=>"Faraday v#{Faraday::VERSION}"}).
        to_return(status: 200, body: api_response.to_json)
      
      uri = URI(api_url)
      response = Faraday.get(uri)

      expect(response.status.to_i).to eql(200)
      expect(response.body.to_json).to include('overcast clouds', 'snow', '269.26')
    end

    it 'responds with "internal server error" 500 when the API is down' do
      api_url = "#{base_api_url}?lat=#{latitude}&lon=#{longitude}"

      stub_request(:get, api_url).
        with(headers: {'Accept'=>'*/*', 'User-Agent'=>"Faraday v#{Faraday::VERSION}"}).
        to_return(status: 500, body: 'Internal Server Error. Ask Tech Admin for assistance.')
      
      uri = URI(api_url)
      response = Faraday.get(uri)

      expect(response.status.to_i).to eql(500)
      expect(response.body).to include('Internal Server Error')
    end
  end
end
