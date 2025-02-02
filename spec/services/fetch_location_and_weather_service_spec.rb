require 'rails_helper'
require Rails.root.join('spec', 'support', 'request_helper')

RSpec.describe FetchLocationAndWeatherService, type: :service do
  # ----------------------------------------------
  # Variables
  # ----------------------------------------------
  let(:valid_zip_code) { '12946' } # Numerically valid, and is a "real" zip code
  let(:invalid_zip_code) { '99999' } # Numberically valid, zip code does not exist

  let(:mock_location_data) do
    # Read and parse the mock data needed for this controller
    JSON.parse(File.read('./spec/fixtures/mock_location_data.json'), symbolize_name: true)
  end
  let(:mock_weather_data) do
    # Read and parse the mock data needed for this controller
    JSON.parse(File.read('./spec/fixtures/mock_weather_data.json'), symbolize_name: true)
  end

  # Initialize subject with the zip_code
  let(:subject) { FetchLocationAndWeatherService.new(zip_code: zip_code) }
  
  # ----------------------------------------------
  # Service Tests
  # ----------------------------------------------
  describe '#call' do
    # ----------------------------------------------
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
        expect(result[:location].to_json).to include('Lake Placid', 'NY', '44.279491', '-73.979871')
      end
    end
    # ----------------------------------------------
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
      # ----------------------------------------------
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

  # ----------------------------------------------
  # Cache Tests
  # ----------------------------------------------
  describe '#cache_data' do
    # Use our awesome shared context routine which handles cache cleanup
    include_context 'with cache'

    let(:zip_code) { valid_zip_code }
    let(:cache_duration) { 30 } # minutes
    let(:mock_block) { double('block') } # use instead of actual api calls
    # ----------------------------------------------
    context 'when location data exists in cache' do
      it 'caches and reuses location data' do
        test_cache_behavior("location_#{zip_code}", mock_location_data)
      end
    end
    # ----------------------------------------------
    context 'when weather data exists in cache' do
      it 'caches and reuses weather data' do
        test_cache_behavior("weather_#{zip_code}", mock_weather_data)
      end
    end
    # ----------------------------------------------
    context 'when cache expires' do  
      it 'expires and fetches fresh data after cache expiration' do
        cache_key = "weather_#{zip_code}"
        mocked_data = mock_weather_data
  
        # Allow the subject to receive the API call
        allow(mock_block).to receive(:call).and_return(mocked_data)
  
        # First call will hit the API and cache the result
        result = cache_data(cache_key, cache_duration) { mock_block.call }
        expect(is_cached?(cache_key)).to eq(true)
        expect(result).to eq(mocked_data)
        expect(mock_block).to have_received(:call).once
  
        # Now, freeze time to simulate cache expiry
        Timecop.travel(Time.now + cache_duration.minutes + 1.second) do
          # Check if the cache has been cleared 
          expect(is_cached?(cache_key)).to eq(false)
          # cached_value = Rails.cache.read(cache_key)
          # expect(cached_value).to be_nil

          # Second call should fetch fresh data since the cache is expired
          fresh_result = cache_data(cache_key, cache_duration) { mock_block.call }
          expect(fresh_result).to eq(mocked_data)
          expect(mock_block).to have_received(:call).twice
        end
      end
    end
  end

  # ----------------------------------------------
  # Helper Methods
  # ----------------------------------------------
  # Helper to mock the API responses
  def mock_api_responses(location: mock_location_data, weather: mock_weather_data)
    allow_any_instance_of(FetchLocationAndWeatherService).to receive(:fetch_location_from_zip).and_return(location)
    allow_any_instance_of(FetchLocationAndWeatherService).to receive(:fetch_weather).and_return(weather)
  end
  # ----------------------------------------------
  # Helper for cacheing tests
  def test_cache_behavior(cache_key, mocked_data)
    # First, mock the return value of the API call to ensure we control the test data
    allow(mock_block).to receive(:call).and_return(mocked_data)

    # cache_key should not exist when we start out
    expect(is_cached?(cache_key)).to eq(false)
    
    # Test Cache Miss (Cache is Empty)
    # First call will hit the API and cache the result
    result = cache_data(cache_key, cache_duration) { mock_block.call }

    # Assert the result is the expected response and that the API was called once
    expect(is_cached?(cache_key)).to eq(true)
    expect(result).to eq(mocked_data)
    # Our mock_block method should only have run once
    expect(mock_block).to have_received(:call).once

    # READ THE CACHE!
    puts "READING CACHE NOW"
    puts Rails.cache.read(cache_key)

    # Second call should use the cache and ignore the API
    cached_result = cache_data(cache_key, cache_duration) { mock_block.call }

    # Assert the result is the expected response and that the API
    # has still only been called once
    expect(is_cached?(cache_key)).to eq(true)
    expect(cached_result).to eq(mocked_data)
    expect(mock_block).to have_received(:call).once
  end
end
