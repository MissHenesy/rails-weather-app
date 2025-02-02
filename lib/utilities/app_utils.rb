module Utilities
  module AppUtils
    # ----------------------------------------------
    # Cache Helpers
    # ----------------------------------------------
    def self.is_cached?(key)
      cached = Rails.cache.read(key)
      Rails.logger.info "Checking cache for key: #{key}: key cached?: #{cached.present?}"
      cached.present?
    end

    def self.cache_data(key, duration, units, &block)
      # &block is a special Ruby syntax that converts the block passed to
      # this method into a Proc (a block of code that can be called later)
      
      Rails.cache.fetch(key, expires_in: duration.send(units)) do
        # Rails.cache.fetch: checks the cache. If cache exists, returns
        # cached value. If cache does not exist, it runs the block of 
        # code, creates a cache, and returns the result.
        
        # The block is called using 'block.call'. It runs when the 
        # cache is NOT already populated with the key we have passed.
        #result = block.call
        block.call
      end
    end
  end
end
