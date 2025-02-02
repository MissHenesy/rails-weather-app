class FetchLocationAndWeatherService < BaseService
    include Common::ApiHelpers

    CACHE_UTILS = Utilities::AppUtils
    VALIDATOR_UTILS = Utilities::ValidatorUtils

    def initialize(zip_code)
        # Load cache settings from our config file
        @cache_config = YAML.load_file(Rails.root.join('config', 'cache_config.yml'))[Rails.env].symbolize_keys
        @cache_duration = @cache_config[:cache_location_duration]
        @cache_units = @cache_config[:cache_location_units]
  
        # @zip_code stores the provided zip_code for use in fetching location and weather data
        @zip_code = zip_code
    end

    def call
        location_data = nil
        weather_data = nil
        errors.add :validation, 'Invalid postal code input.' unless is_valid_zip?(@zip_code) 

        if errors.empty?
            location_data = fetch_location_from_zip
            weather_data = fetch_weather(location_data)
        end

        { location: location_data, weather: weather_data }
    end

    private

    def fetch_location_from_zip
        # Call our cache_data method and pass our cache_key
        # and expiration value.
        CACHE_UTILS.cache_data("location_#{@zip_code}", @cache_duration, @cache_units) do
            # This block of code will only run if the cache does not 
            # already have the data
            fetch_data_from_api(FetchLocationByZipService, @zip_code)
        end
    end

    def fetch_weather(location_data)
        return nil if location_data.nil?

        # Call our cache_data method and pass our cache_key
        CACHE_UTILS.cache_data("weather_#{@zip_code}", @cache_duration, @cache_units) do
            # This block of code will only run if the cache does not 
            # already have the data
            fetch_data_from_api(FetchWeatherService, location_data)
        end
    end

    def is_valid_zip?(zip)
        VALIDATOR_UTILS.is_valid_zip?(zip.to_s)
    end
end
