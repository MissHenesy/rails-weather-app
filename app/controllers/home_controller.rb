class HomeController < ApplicationController
  def index
  end

  def weather_request
    # Access cache info
    @is_cached = Utilities::AppUtils.is_cached?("weather_#{params[:zip_code]}")

    # Call service and set location/weather instance vars
    svc_request = FetchLocationAndWeatherService.call(params[:zip_code])
    @location_data = svc_request.result[:location]
    @weather_data = svc_request.result[:weather]

    if @weather_data.present?
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'Weather results cannot be dynamically displayed without enhanced browser features.' }
        format.turbo_stream {
          render turbo_stream: [
            # Display weather results
            turbo_stream.update('weather_results',
              partial: 'home/weather_results',
              locals: { location_data: @location_data, weather_data: @weather_data , is_cached: @is_cached }
            ),

            # Clear out any error messages
            turbo_stream.update('error_messages',
              partial: 'layouts/error_messages',
              locals: { error_messages: nil }
            )
          ]
        }
      end
    else
      respond_to do |format|
        # Use a generic error message if Turbo is disabled
        format.html { redirect_to root_path, alert: 'Invalid location or weather data unavailable.' }
      
        # Otherwise, collect all error messages from svc_request.errors
        if svc_request.errors&.any? 
          error_messages = collect_error_messages(svc_request.errors)
        else
          error_messages = nil
        end
        
        format.turbo_stream {
          render turbo_stream: [
              turbo_stream.update('weather_results',
                partial: 'home/weather_results',
                locals: { location_data: nil, weather_data: nil, is_cached: false }
              ),
              turbo_stream.update('error_messages',
                partial: 'layouts/error_messages',
                locals: { error_messages: error_messages }
              )
          ]
        }
      end
    end
  end

  private

  def weather_request_params
    # Permit only the expected parameters
    params.require(:zip_code).permit(:zip_code)
  end
end
