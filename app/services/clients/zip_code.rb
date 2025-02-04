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
           
            else
                err_msg = case response.status
                          when 404
                            'Could not find a location for the zip code you entered. Try another one!'
                          when 429
                            Rails.logger.info "Failed to fetch Location Data because of Too Many Requests: #{response.status}"                   
                            'Too Many Requests (Request Limit Exceeded). Please try again later.'
                          else
                             "Failed to fetch Location Data. Reason: #{response.reason_phrase}. Status Code: #{response.status}"
                          end

                errors.add(:zip_code_api, err_msg)
                return nil
            end
        end
    end
end
