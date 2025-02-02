module Utilities
  module DateUtils
    def self.convertTimestampToReadableDate(timestamp)
      # Receives a timestamp, and returns it as 
      # a human readable value, e.g.:: "Tuesday, January 29 2025" 
      new_date = Time.at(timestamp).strftime('%A, %B %e, %Y')
      Utilities::StringUtils.trim_extra_spaces(new_date)
    end
  end
end
