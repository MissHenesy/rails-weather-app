require 'rails_helper'
require 'Nokogiri'

RSpec.describe HomeController, type: :controller do
  include MockLocationData
  include MockWeatherData

  let(:valid_zip_code) { '12946' }  # Valid zip code
  let(:invalid_zip_code) { '99999' }  # Invalid zip code
  let(:bad_zip_code) { 'abcde' } # Just bad input
  let(:mock_location) { mock_location_data }
  let(:mock_weather) { mock_weather_data }
  
  # Mock the FetchLocationAndWeatherService
  before do
    # Allow FetchLocationAndWeatherService to return mocked data
    allow(FetchLocationAndWeatherService).to receive(:call).and_return(double(result: { location: mock_location_data, weather: mock_weather_data }))
  end
  
  describe 'POST #weather_request' do
    context 'when weather data is available' do
      before do
        # Mocking the service call to return sample weather data
        allow(FetchLocationAndWeatherService).to receive(:call).with(valid_zip_code)
          .and_return(OpenStruct.new(result: {
            location: mock_location_data,
            weather: mock_weather_data
          }))
        
        # Mimicking the POST request with a valid zip code
        post :weather_request, params: { zip_code: valid_zip_code }, format: :turbo_stream
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:success)
      end

      it 'renders the correct turbo stream updates' do
        expect(response.body).to include('<turbo-stream action="update" target="weather_results">')
        expect(response.body).to include('<turbo-stream action="update" target="error_messages">')
      end
    end

    context 'when Turbo is disabled' do
      let(:service) { instance_double('FetchLocationAndWeatherService') }
      let(:err_msg_for_bad_data) { 'Weather results cannot be dynamically displayed without enhanced browser features.' }

      before do
        # Use a mock for the service call
        allow(FetchLocationAndWeatherService).to receive(:new).and_return(double('service', errors: [err_msg_for_bad_data]))
        # Simulate the request with Turbo disabled by passing `format: :html`
        post :weather_request, params: { zip_code: bad_zip_code }, format: :html
      end

      it 'returns a redirect response' do
        expect(response).to have_http_status(:redirect)
      end

      it 'sets the flash alert with the error message' do
        # Check if the flash alert contains the expected error message
        expect(flash[:alert]).to eq(err_msg_for_bad_data)
      end
    end
  end
end
