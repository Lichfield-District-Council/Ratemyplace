bufferapp_config_file = File.join(Rails.root,'config','bufferapp.yml')
raise "#{bufferapp_config_file} is missing!" unless File.exists? bufferapp_config_file
BUFFER_CONFIG = YAML.load_file(bufferapp_config_file)[Rails.env].symbolize_keys