require './spec/support/request_helper'

RSpec.describe 'zip_code_api requests', type: :request do
  
  let(:valid_zip_code) { '12946'}
  let(:invalid_zip_code) { '99999' }
  let(:base_api_url) { 'https://www.zipcodeapi.com/rest/info.json' }

  describe 'Requests data from zipcodeapi.com with GET' do

    it 'returns location data when given a valid zip code' do
      json_data = File.read('spec/fixtures/mock_location_data.json')
      api_response = JSON.parse(json_data)
      api_url = "#{base_api_url}/#{valid_zip_code}/degrees"

      stub_request(:get, api_url).
        with(headers: {'Accept'=>'*/*', 'User-Agent'=>"Faraday v#{Faraday::VERSION}"}).
        to_return(status: 200, body: api_response.to_json)
      
      uri = URI(api_url)
      response = Faraday.get(uri)

      expect(response.status.to_i).to eql(200)
      expect(response.body.to_json).to include('Lake Placid', 'NY', '12946')
    end

    it 'responds with "internal server error" 500 when the API is down' do
      api_url = "#{base_api_url}/#{invalid_zip_code}/degrees"

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
