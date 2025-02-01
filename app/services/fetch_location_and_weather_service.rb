class FetchLocationAndWeatherService < BaseService
    include Common::ApiHelpers
    CACHE_DURATION = 30

    def initialize(zip_code)
        @zip_code = zip_code
    end

    def call
        location_data = fetch_location_from_zip
        weather_data = fetch_weather(location_data)

        { location: location_data, weather: weather_data }
    end

    private

    def fetch_location_from_zip
        # Call our cache_data method and pass our cache_key
        # and expiration value.
        cache_data("location_#{@zip_code}") do
            # This block of code will only run if the cache does not 
            # already have the data
            fetch_data_from_api(FetchLocationByZipService, @zip_code)
        end
    end

    def fetch_weather(location_data)
        return nil if location_data.nil?

        # Call our cache_data method and pass our cache_key
        cache_data("weather_#{@zip_code}") do
            # This block of code will only run if the cache does not 
            # already have the data
            fetch_data_from_api(FetchWeatherService, location_data)
        end
    end

    def cache_data(key, &block)
        if Utilities::AppUtils.is_cached?(key)
            Rails.logger.info "KEY IS CACHED: #{key}"
        end
        # &block is a special Ruby syntax that converts the block passed to
        # this method into a Proc (a block of code that can be called later)
        Rails.cache.fetch(key, expires_in: CACHE_DURATION.minutes) do
            # The block is called using 'block.call'. It runs when the 
            # cache is NOT already populated with the key we have passed.
            block.call
        end
    end
end
