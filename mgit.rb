require 'yaml'

MGIT_CONFIGURATION_ENV = 'MGIT_CONFIGURATION'.freeze

def configuration_defined?
  if ENV[MGIT_CONFIGURATION_ENV].nil? || ENV[MGIT_CONFIGURATION_ENV].empty?
    false
  else
    true
  end
end

unless configuration_defined?
  puts "Please define configuration in #{MGIT_CONFIGURATION_ENV}"
  exit(1)
end

config_file = ENV[MGIT_CONFIGURATION_ENV]

puts "Loading configuration from #{config_file}"
mgit_config = YAML.load_file(config_file)

puts mgit_config.inspect.to_s
