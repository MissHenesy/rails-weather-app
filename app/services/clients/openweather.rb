module Clients
  class Openweather < ::BaseService
    API_KEY = ENV['OPENWEATHER_API_KEY']
    BASE_API_URL = "https://api.openweathermap.org/data/3.0/onecall?appid=#{API_KEY}".freeze
    BASE_ICON_URL = 'https://openweathermap.org/img/wn'

    NUMBER_UTILS = Utilities::NumberUtils
    DATE_UTILS = Utilities::DateUtils
    
    def initialize(latitude, longitude)
      @latitude = latitude
      @longitude = longitude
    end

    def call
        fetch_weather
    end

    private

    def fetch_weather
      Rails.logger.info "** FETCHING WEATHER DATA WITH #{@latitude} / #{@longitude}"
      api_url = "#{BASE_API_URL}&lat=#{@latitude}&lon=#{@longitude}"
      
      # Exclude info we are not using
      api_url += "&exclude=minutely,hourly,alerts"

      response = Faraday.get(api_url) do |req|
        req.headers['Accept'] = 'application/json'
      end

      handle_response(response)
    end

    def handle_response(response)
      if response.success?
          Rails.logger.info 'Successfully fetched weather data!'
          return final_weather_result(response)
      else
          errors.add(:weather_api, "Failed to fetch Weather Data: #{response.status}")
      end
    end

    def final_weather_result(response)
      weather_data = {}
      res = JSON.parse(response.body)
      
      # Fetch current weather
      current_dt = DATE_UTILS.convertTimestampToReadableDate(res['current']['dt'])
      current_temp = NUMBER_UTILS.convertKelvinToFarenheit(res['current']['temp'])
      current_conditions = res['current']['weather'][0]['description']
      current_icon = getWeatherImage(res['current']['weather'][0]['icon'])

      # Add current weather to weather_data
      weather_data[:current] = {
        dt: current_dt,
        temp: current_temp,
        conditions: current_conditions,
        icon: current_icon
      }

      # Loop to retrieve extended
      i = 0
      extended_forecast = []

      while i < res['daily'].size
        day = res['daily'][i]

        # Only add weather info when this date is greater than
        # the current date
        day_dt = DATE_UTILS.convertTimestampToReadableDate(day['dt'])
        
        if (day['dt'] > res['current']['dt'])
          extended_forecast << {
            dt: day_dt == current_dt ? "TODAY" : day_dt,
            min_temp: NUMBER_UTILS.convertKelvinToFarenheit(day['temp']['min']),
            max_temp: NUMBER_UTILS.convertKelvinToFarenheit(day['temp']['max']),
            conditions: day['summary'],
            icon: getWeatherImage(day['weather'][0]['icon'])
          }
        end

        i += 1
      end

      # Add extended forecast to weather_data
      weather_data[:forecast] = extended_forecast

      # Return completed weather_data
      weather_data
    end

    private 

    def getWeatherImage(icon_val)
      "#{BASE_ICON_URL}/#{icon_val}@4x.png"
    end
  end
end
