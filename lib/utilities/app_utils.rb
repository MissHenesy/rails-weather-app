module Utilities
  module AppUtils
    def self.is_cached?(key)
      cached = Rails.cache.read(key)
      cached.present?
    end
  end
end
