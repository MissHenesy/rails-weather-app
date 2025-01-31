require 'rails_helper'

RSpec.describe FetchLocationAndWeatherService, type: :service do
  # Use our awesome shared context routine which handles cache cleanup
  include_context 'with cache'

  include MockLocationData
  include MockWeatherData
  
  let(:valid_zip_code) { '12946' } # Numerically valid, and is a "real" zip code
  let(:invalid_zip_code) { '99999' } # Numberically valid, zip code does not exist
  let(:location_data) { mock_location_data }
  let(:weather_data) { mock_weather_data }

  # Initialize subject with the zip_code
  let(:subject) { FetchLocationAndWeatherService.new(zip_code: zip_code) }
  
  # Helper to mock the API responses
  def mock_api_responses(location: mock_location_data, weather: mock_weather_data)
    allow_any_instance_of(FetchLocationAndWeatherService).to receive(:fetch_location_from_zip).and_return(location)
    allow_any_instance_of(FetchLocationAndWeatherService).to receive(:fetch_weather).and_return(weather)
  end

  describe '#call' do
    context 'when zip code is valid' do
      let(:zip_code) { valid_zip_code }

      before do
        # Mock the services
        mock_api_responses(location: mock_location_data, weather: mock_weather_data)
      end

      it 'returns location and weather data' do
        result = subject.call
        
        # Ensure the location and weather data are returned correctly
        expect(result[:location]).to eq(mock_location_data)
        expect(result[:weather]).to eq(mock_weather_data)
  
        # Ensure the location data is not nil and contains the expected data
        expect(result[:location]).not_to be_nil
        expect(result[:location]).to include(city: 'Lake Placid', state: 'NY', lat: '44.279491', lng: '-73.979871')
      end
    end

    context 'when zip code is invalid' do
      let(:zip_code) { invalid_zip_code }
      
      before do
         # Mock the service behavior for an invalid zip code
         mock_api_responses(location: nil, weather: nil)
      end

      it 'returns nil for location and weather data' do
        result = subject.call
        
        # Ensure that both location and weather data are nil for invalid zip
        expect(result[:location]).to be_nil
        expect(result[:weather]).to be_nil
      end
    end

    context 'when weather data is unavailable' do
      let (:zip_code) { valid_zip_code }
      let (:service) { FetchLocationAndWeatherService.new(zip_code) }
      
      before do
        # Mock only the location data and return nil for weather
        mock_api_responses(location: mock_location_data, weather: nil)
      end

      it 'returns location data with nil weather data' do
        result = subject.call

        # Ensure the location data is returned and weather data is nil
        expect(result[:location]).to eq(mock_location_data)
        expect(result[:weather]).to be_nil
      end
    end
  end

  # Test that cacheing works as expected
  describe '#cache_data' do
    let(:zip_code) { valid_zip_code }

    context 'when location data exists in cache' do
      it 'caches and reuses location data' do
        test_cache_behavior("location_#{zip_code}", location_data, FetchLocationByZipService)
      end
    end

    context 'when weather data exists in cache' do
      it 'caches and resuses weather data' do
        test_cache_behavior("weather_#{zip_code}", weather_data, FetchWeatherService)
      end
    end

    context 'when cache expires' do
      let(:cache_duration) { 30 } # minutes
  
      it 'expires and fetches fresh data after cache expiration' do
        test_key = "weather_#{zip_code}"
        test_value = mock_weather_data
  
        # Allow the subject to receive the API call
        allow(subject).to receive(:fetch_data_from_api).and_return(test_value)
  
        # First call will hit the API and cache the result
        result = subject.send(:cache_data, test_key) do
          subject.fetch_data_from_api(FetchLocationByZipService, zip_code)
        end
        expect(result).to eq(test_value)
        expect(subject).to have_received(:fetch_data_from_api).once
  
        # Now, freeze time to simulate cache expiry
        Timecop.travel(Time.now + cache_duration.minutes + 1.second) do
          # Check if the cache has been cleared (for debugging)
          cached_value = Rails.cache.read(test_key)
          expect(cached_value).to be_nil

          # Second call should fetch fresh data since the cache is expired
          fresh_result = subject.send(:cache_data, test_key) do
            subject.fetch_data_from_api(FetchLocationByZipService, zip_code)
          end
          expect(fresh_result).to eq(test_value)
          expect(subject).to have_received(:fetch_data_from_api).twice
        end
      end
    end

    def test_cache_behavior(test_key, test_val, api_service)
      # Mock the return value of the API call to ensure we control the test data
      allow(subject).to receive(:fetch_data_from_api).and_return(test_val)

      # First call will hit the API
      result = subject.send(:cache_data, test_key) do
        subject.fetch_data_from_api(api_service, zip_code)
      end
      expect(result).to eq(test_val)
      expect(subject).to have_received(:fetch_data_from_api).once

      # Second call should use the cache and ignore the API
      cached_result = subject.send(:cache_data, test_key) do
        subject.fetch_data_from_api(api_service, zip_code)
      end
      expect(cached_result).to eq(test_val)
      expect(subject).to have_received(:fetch_data_from_api).once
    end
  end
end
