class FetchLocationByZipService < BaseService
    def initialize(zip_code)
        @zip_code = zip_code
    end

    def call
        # Return immediately if we have invalid data
        return errors.add :validation, 'Missing location input.' if @zip_code.empty?
        return errors.add :validation, 'Invalid postal code input.' unless is_valid_postal_code?
        
        # Otherwise, continue with our routine
        fetch_location_details
    end

  private

    def fetch_location_details
        svc_request = Clients::ZipCode.call(@zip_code)
      
        # If the request failed, add errors and return nil
        if svc_request.failure?
            errors.add_multiple_errors(svc_request.errors)
            return nil
        end

        # Otherwise, return our result
        svc_request.result
    end

    def is_valid_postal_code?
        Utilities::ValidatorUtils.is_valid_zip?(@zip_code)
    end
end
