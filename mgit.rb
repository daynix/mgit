require 'yaml'

# MGit - multiple git repositories manager
class MGit
  def initialize
    @config_file = ENV[MGIT_CONFIGURATION_ENV]
  end

  def dump_config
    config = read_config
    puts 'Dumping configuration:'
    puts
    puts "\tProject directory: #{config['project_directory']}"
    puts
    puts "\tListing repositories in the project:"
    config['repos'].each do |repo|
      dump_repo_config(repo)
    end
  end

  private

  MGIT_CONFIGURATION_ENV = 'MGIT_CONFIGURATION'.freeze

  def configuration_defined?
    if @config_file.nil? || @config_file.empty?
      false
    else
      true
    end
  end

  def read_config
    unless configuration_defined?
      throw RuntimeError.new("Please define configuration file in \
#{MGIT_CONFIGURATION_ENV} environment variable")
    end
    YAML.load_file(@config_file)
  end

  def dump_repo_config(repo)
    puts "\t\t#{repo.keys.first}"
    puts "\t\tUpstream url: #{repo['upstream']}"
    puts "\t\tDevelopment url: #{repo['dev']}"
    puts "\t\tGit reference: #{repo['ref']}"
    puts
  end
end

mgit = MGit.new
mgit.dump_config
