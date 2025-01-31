module Utilities
  module ValidatorUtils
    STRING_UTILS = Utilities::StringUtils

    # ----------------------------------------------
    # Numbers
    # ----------------------------------------------
    def self.is_numeric?(value)
      value.is_a?(Numeric)
    end

    def self.is_integer?(value)
      value.is_a?(Integer)
    end
    # ----------------------------------------------
    # Postal Codes
    # ----------------------------------------------
    # Validate U.S. postal codes
    def self.is_valid_us?(postal_code)
        # Clean up user input before validating
        pc = STRING_UTILS.clean_for_us(postal_code)
        # Check that input is valid for U.S. postal codes
        pc && pc.match(/^[0-9]{5}$/) ? true : false
    end

    def self.is_valid_zip?(postal_code)
        is_valid_us?(postal_code)
    end
  end
end
