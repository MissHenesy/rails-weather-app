require 'rails_helper'
require Rails.root.join('spec', 'support', 'request_helper')

RSpec.describe HomeController, type: :controller do
  let(:valid_zip_code) { '12946' }  # Valid zip code
  let(:invalid_zip_code) { '99999' }  # Invalid zip code
  let(:bad_zip_code) { 'abcde' } # Just bad input

  let(:mock_data) do
    # Read and parse the mock data needed for this controller
    JSON.parse(File.read('./spec/fixtures/mock_location_and_weather_data.json'), symbolize_name: true)
  end
  
  describe 'POST #weather_request' do
    context 'when weather data is available' do
      before do
        # Mock the service call to return sample weather data
        allow(FetchLocationAndWeatherService).to receive(:call).
          and_return(OpenStruct.new(result: mock_data))

        # Mimic the POST request with a valid zip code
        post weather_request_path, { zip_code: valid_zip_code }, format: :turbo_stream
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end

