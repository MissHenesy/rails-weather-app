module Utilities
  module NumberUtils
      # ----------------------------------------------
      # Temperature Helpers
      # ----------------------------------------------
      def self.convertKelvinToFarenheit(temp)
        # Receives a Kelvin value
        # Returns it as Farenheit rounded to nearest integer
        ((temp - 273.15) * 9/5 + 32).round
      end
  end
end
