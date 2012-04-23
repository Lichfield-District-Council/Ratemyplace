foursquare_config_file = File.join(Rails.root,'config','foursquare.yml')
raise "#{foursquare_config_file} is missing!" unless File.exists? foursquare_config_file
FOURSQUARE_CONFIG = YAML.load_file(foursquare_config_file).symbolize_keys