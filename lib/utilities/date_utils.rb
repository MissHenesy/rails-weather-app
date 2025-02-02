module Utilities
  module DateUtils
    def self.convertTimestampToReadableDate(timestamp)
      # Receives a timestamp, and returns it as 
      # a human readable value, e.g.:: "Tuesday, January 29 2025" 
      Time.at(timestamp).strftime('%A, %B %e, %Y').strip_excess_spaces
    end
  end
end
