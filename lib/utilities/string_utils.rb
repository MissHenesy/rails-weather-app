module Utilities
  module StringUtils
      # ----------------------------------------------
      # General String Helpers
      # ----------------------------------------------
      def self.strip_spaces_and_symbols(s)
        s.gsub(/[^a-zA-Z0-9]/, '')
      end

      def self.trim_to_5_chars(s)
        s.match(/\d{5}/) ? s.match(/\d{5}/)[0] : nil
      end

      def self.trim_extra_spaces(s)
        s.gsub(/\s+/, ' ')
      end

      # ----------------------------------------------
      # Postal Code Helpers
      # ----------------------------------------------
      # Clean up user postal_code input (for U.S. codes)
      # - Strip spaces / symbols
      # - Trim to 5 characters
      def self.clean_for_us(postal_code)
        pc = strip_spaces_and_symbols(postal_code).downcase
        pc = trim_to_5_chars(pc)
      end
  end
end
