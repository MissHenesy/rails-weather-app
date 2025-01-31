module HomeHelper

  # Amalgamate error messages the Home Controller
  # may have received after calling on API 
  # services
  def collect_error_messages(errors)
    error_messages = []
    # Loop through errors and collect messages
    errors.each do |err_type, err_msg|
      error_messages << err_msg
    end
    error_messages
  end
end
