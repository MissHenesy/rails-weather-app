module HomeHelper
  def cache_duration_and_units
    # Read cache settings from the config file
    cache_config = YAML.load_file(Rails.root.join('config', 'cache_config.yml'))[Rails.env].symbolize_keys
    cache_duration = cache_config[:cache_location_duration]
    cache_units = cache_config[:cache_location_units]
    
    "#{cache_duration} #{cache_units}"
  end
end
