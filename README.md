# rails-weather-app
This is a simple weather app built using Ruby on Rails 7.1.5.1, which allows users to input a U.S. Zip Code and retrieve current weather conditions, along with an extended forecast.

## Features:
  * Zip Code Input: Users can enter a U.S. Zip Code to get localized weather information.
  * Current Weather: Displays the current weather conditions for the given zip code.
  * Extended Forecast: Provides a forecast for upcoming weather conditions based on the provided zip code.

## Technology Used
  * Framework: Ruby on Rails 7.1.5.1
  * Language: Ruby 3.3.3
  * Tests: Rspec
  * APIs Used:
    *	[ZIPcodeAPI](https://www.zipcodeapi.com): Used for retrieving location data based on U.S. Zip Codes.
    * [OpenWeather](https://openweathermap.org): Used to fetch real-time weather data and forecast information.

## Constraints:
  * The app currently only supports U.S. Zip Codes for weather retrieval.

## How It Works:
  1.	User Input: A user enters a valid U.S. Zip Code.
  2.	Location Data: The app retrieves location details (latitude, longitude, etc.) based on the zip code via the ZIPcodeAPI.
  3.	Weather Data: The app fetches current weather conditions and extended forecasts from OpenWeather using the retrieved location details.
  4.	Display: The weather data is then displayed to the user in a readable format.

## Potential Future Enhancements:
  * Support for additional international zip/postal codes.
  * Integration with more weather APIs for richer data.
  * Improved UI/UX design for better user interaction.

## Installation
To run the app locally:
	1.	Clone the repository.
	2.	Install the required dependencies.
	3.	Set up API keys for ZIPcodeAPI and OpenWeather in the .env file.
	4.	Run the Rails server: rails server
	5.	Access the app at http://localhost:3000

## Running Tests
To run tests:
```
# Run all tests
> bundle exec rspec

# Run all tests in a directory
> bundle exec rspec spec/controllers

# Run a specific file
> bundle exec rspec path/to/file_spec.rb
```

## Note for Developers:
  * Cache Layer: A caching mechanism is in place to avoid excessive API calls and reduce latency. Weather data is cached and reused until the cache expires (configurable).
  * Time Handling: Time-based features are managed using Timecop for testing time-dependent behaviors, such as cache expiration.
