class HomeController < ApplicationController

  def index
    # Extract and delete the weather data hash from session
    weather_data = session.delete(:weather_data)&.deep_symbolize_keys

    # Determine if we have retrieved weather_data in the session.
    # If so, display it.
    if weather_data
      @is_cached = weather_data[:is_cached]
      @location_data = weather_data[:location]
      @weather_data = weather_data[:weather]
      @error_messages = weather_data[:error_messages]
    else
      # Default to nil if no session data is found
      @location_data = @weather_data = @is_cached = @error_messages = nil
    end
  end

  def weather_request 
    @zip_code = params[:zip_code]
    cache_key = "weather_#{@zip_code}"
    @is_cached = Utilities::AppUtils.is_cached?(cache_key)
    svc_request = FetchLocationAndWeatherService.call(@zip_code)
    
    if svc_request.result[:weather].present? 
      @location_data = svc_request.result[:location]
      @weather_data = svc_request.result[:weather]
      @error_messages = nil
    else
      # When weather data is missing, check for location errors
      location_err = find_location_error
      @error_messages = location_err.present? ? [location_err] : collect_svc_errors(svc_request)
    end

    respond_to do |format|
     
      flash[:error] = @error_messages if @error_messages.present?

      format.html do
        session[:weather_data] = {
          is_cached: @is_cached,
          location: @location_data, 
          weather: @weather_data,
          error_messages: @error_messages
        }
        redirect_to root_path
      end

      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.update('weather_results',
            partial: 'home/weather_results',
            locals: { location_data: @location_data, weather_data: @weather_data , is_cached: @is_cached } 
          ),
          turbo_stream.update('flash', 
            partial: 'layouts/flash',
            locals: { messages: flash }
          )
        ]
      }
    end
  end

  private

  def find_location_error
    location_key = "location_#{@zip_code}"
    return nil unless Utilities::AppUtils.is_cached?(location_key)
    
    location_cache = Rails.cache.read(location_key)
    location_cache[:err_message].present? ? location_cache[:err_message] : nil
  end

  def collect_svc_errors(svc_request)
    svc_request.errors&.any? ? collect_error_messages(svc_request.errors) : []
  end

  def weather_request_params
    # Permit only the expected parameters
    params.require(:zip_code).permit(:zip_code)
  end
end
