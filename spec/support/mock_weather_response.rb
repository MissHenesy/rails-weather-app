require 'ostruct'
require 'json'

module MockWeatherResponse
  def mock_weather_response
    {
      "success?": true,
      "status": 200,
      "body": {
        "current": {
          "dt": 1738272150,
          "temp": 262.81,
          "weather": {
            "description": "overcast clouds",
            "icon": "04d"
          }
        },
        "daily": [
          {
            "dt": 1738256400,
            "summary": "snowy",
            "temp": {
              "min": 247.38,
              "max": 265.31
            },
            "weather": {
              "icon": "13d"
            }
          },
          {
            "dt": 1738342800,
            "summary": "snow",
            "temp": {
              "min": 264.8,
              "max": 273.77
            },
            "weather": {
              "icon": "13d"
            }
          },
          {
            "dt": 1738429200,
            "summary": "rain",
            "temp": {
              "min": 247.46,
              "max": 269.26
            },
            "weather": {
              "icon": "10d"
            }
          }
        ]
      },
      "content_type": "application/json"
    }
  end
end
