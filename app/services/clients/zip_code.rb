module Clients
    class ZipCode < ::BaseService
        API_KEY = ENV['ZIP_CODE_API_KEY'].freeze
        BASE_URL = "https://www.zipcodeapi.com/rest/#{API_KEY}/info.json".freeze
        
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
           
            elsif response.status == 404
                # User input an invalid zip code and no location could be found.
                # Show a more readable error message.
                err_msg = "Could not find a location for the zip code you entered. Try another one!"
                errors.add(:zip_code_api, err_msg)
            
            elsif response.status == 429
                Rails.logger.info "Failed to fetch Location Data because of Too Many Requests: #{response.status}"
                              
                err_msg = "Too Many Requests (Request Limit Exceeded). Please try again later."
                errors.add(:zip_code_api, err_msg)
            
            else
                err_msg = "Failed to fetch Location Data. "
                err_msg += "Reason: #{response.reason_phrase}. Status Code: #{response.status}"

                errors.add(:zip_code_api, err_msg)
                return nil
            end
        end
    end
end
