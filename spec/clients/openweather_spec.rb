require 'rails_helper'
require Rails.root.join('spec', 'support', 'request_helper')

RSpec.describe 'Openweather', type: :client do
  let(:mock_weather_data) do
    JSON.parse(File.read('./spec/fixtures/mock_weather_data.json'), sybmolize_names: true)
  end
  let(:mock_transformed_weather_data) do
    JSON.parse(File.read('./spec/fixtures/mock_transformed_weather_data.json'), sybmolize_names: true)
  end
  let(:api_response) do
    instance_double(Faraday::Response, success?: true, body: mock_weather_data.to_json)
  end
  
  let(:latitude) { '44.279491' }
  let(:longitude) { '-73.979871' }
  let(:client) { Clients::Openweather.new(latitude, longitude) }

  it 'transforms raw API response correctly' do
    puts "this is the mock weather data"
    puts mock_weather_data.to_json

    puts "api response"
    puts api_response

    result = client.send(:handle_response, api_response)
    expected_result = mock_transformed_weather_data.deep_symbolize_keys
    puts "RESULT IS:"
    puts result

    puts "EXPECTED RESULT IS:"
    puts expected_result
    expect(result).to eq(expected_result)
  end

end

 