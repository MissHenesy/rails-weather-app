module Common
  module ApiHelpers
      # Methods in this module save us from having to write 
      # the same or similar methods.
      def fetch_data_from_api(service_class, *args)
          service_instance = service_class.call(*args)

          if service_instance.success?
              service_instance.result
          else
              errors.add_multiple_errors(service_instance.errors)
              nil
          end
      end
  end
end
