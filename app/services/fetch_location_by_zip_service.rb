class FetchLocationByZipService < BaseService
    def initialize(zip_code)
        @zip_code = zip_code
    end

    def call
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
end
