fsa_config_file = File.join(Rails.root,'config','fsa.yml')
raise "#{fsa_config_file} is missing!" unless File.exists? fsa_config_file
FSA_CONFIG = YAML.load_file(fsa_config_file)[Rails.env].symbolize_keys