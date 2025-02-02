CACHE_CONFIG = YAML.load_file(Rails.root.join('config', 'cache_config.yml'))[Rails.env].symbolize_keys
