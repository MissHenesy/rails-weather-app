# Our BaseService allows us to abstract frequently used methods.
# Borrowed from:
# https://www.driftingruby.com/episodes/service-objects-for-api-interactions-with-twilio

class BaseService
  class << self
      def call (*arg)
          new(*arg).constructor
      end
  end

  attr_reader :result
  def constructor
      @result = call
      self
  end

  def success?
      !failure?
  end

  def failure?
      errors.any?
  end

  def errors
      @errors ||= Common::Errors.new
  end

  def call
      fail NotImplementedError unless defined?(super)
  end
end
