module Clients
    class ZipCode < ::BaseService
        API_KEY = ENV['ZIP_CODE_API_KEY'].freeze
        BASE_URL = "https://www.zipcodeapi.com/rest/#{API_KEY}/info.json".freeze
        
        # This is a hard-coded location result, in case my very limited free 
        # zipcodeapi account returns a 429 HTTP Status ("Too Many Requests")
        FALLBACK_LOCATION = { lat: '37.306486', lng: '-122.080684', 
          city: 'Cupertino', state: 'CA', zip_code: '95014' 
        }.freeze

        def initialize(zip_code)
            @zip_code = zip_code
        end

        def call
            fetch_location_from_zip
        end

        private

        def fetch_location_from_zip
            Rails.logger.info "** FETCHING LOCATION DETAILS WITH #{@zip_code}"

            api_url = "#{BASE_URL}/#{@zip_code}/degrees"
            response = Faraday.get(api_url)
            handle_response(response)
        end

        def handle_response(response)
            if response.success?
                Rails.logger.info 'Successfully fetched location data!'
                
                res = JSON.parse(response.body)
                return { lat: res['lat'], lng: res['lng'], city: res['city'], state: res['state'], zip_code: res['zip_code'] }
            elsif response.status === 404
                # User input an invalid zip code and no location could be found.
                # Show a more readable error message.
                errors.add(:zip_code_api, "Could not find a location for the zip code you entered. Try another one!")
            elsif response.status == 429
                Rails.logger.info "Failed to fetch Location Data because of Too Many Requests: #{response.status}"
                Rails.logger.info "Retrieving hard-coded location so we can show something on the screen for these development purposes"
                
                # My poor free account for the zipcodeapi reached its daily limit
                # of 240 calls per day; showing a hard-coded location in order 
                # to have some data for the user. And of course, we would never
                # do this in Production!
                
                # Add a message to explain what we are doing
                err_msg = "We've reached our request limit. However, to ensure "
                err_msg += "you can still view results, we are displaying data "
                err_msg += "for #{FALLBACK_LOCATION[:city]}, #{FALLBACK_LOCATION[:state]}."
                errors.add(:zip_code_api, "We have reached our request limit. Here is ")
  
                return FALLBACK_LOCATION

                # For production, we would of course return a real error message:
                # errors.add(:zip_code_api, "We've reached our request limit. Please try again later.")
                # return nil
            else
                err_msg = "Failed to fetch Location Data. "
                err_msg += "Reason: #{response.reason_phrase}. Status Code: #{response.status}"

                errors.add(:zip_code_api, err_msg)
                return nil
            end
        end
    end
end
