class FetchWeatherService < BaseService
  def initialize(location_data)
      @location_data = location_data
      @latitude = @location_data[:lat]
      @longitude = @location_data[:lng]
  end

  def call
    if @latitude.blank? || @longitude.blank?
        return errors.add :validation, 'Missing latitude/longitude'
    end

    fetch_weather
  end

  private

  def fetch_weather
      svc_request = Clients::Openweather.call(@latitude, @longitude)

      Rails.logger.info('** FetchWeather Details:')
      Rails.logger.info("Success? #{svc_request.success?}")
      
      if svc_request.failure?
          errors.add_multiple_errors(svc_request.errors)
          return nil
      end

      svc_request.result
  end
end
