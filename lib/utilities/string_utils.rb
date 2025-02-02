module Utilities
  module StringUtils
      # ----------------------------------------------
      # Postal Code Helpers
      # ----------------------------------------------
      # Clean up user postal_code input (for U.S. codes)
      # - Strip spaces / symbols
      # - Trim to 5 characters
      def self.clean_for_us(postal_code)
        pc = postal_code.strip_spaces_and_symbols
        pc = pc&.trim_to_5_chars
        pc&.downcase
      end
  end
end
