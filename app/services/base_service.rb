# The `BaseService` class abstracts common functionality for service objects, 
# providing a foundation to standardize error handling, success/failure checks, 
# and the execution flow. It ensures that every service object inherits core 
# behavior such as managing results and errors.
#
# This pattern is useful for encapsulating business logic and making it easy 
# to extend for specific use cases, such as API interactions or complex operations.
#
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
