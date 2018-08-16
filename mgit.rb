require 'yaml'
require 'logger'
require 'commander/import'
require 'git'
require 'fileutils'

# MGit - multiple git repositories manager
class MGit
  def initialize
    @config_dir = ENV[MGIT_CONFIGURATION_ENV]
    unless configuration_defined?
      throw RuntimeError.new("Please define configuration directory in \
#{MGIT_CONFIGURATION_ENV} environment variable")
    end
    @config_file = @config_dir + '/mgit.yml'
    @config_local_file = @config_dir + '/mgit.local.yml'
    @config = read_config(@config_file)
    @local_config = read_config(@config_local_file)
  end

  def dump_config
    puts 'Dumping configuration:'
    puts
    puts "\tProject directory: #{@local_config['project_directory']}"
    puts
    puts "\tListing repositories in the project:"
    @config['repos'].each do |repo|
      dump_repo_config(repo)
    end
  end

  def status
    @config['repos'].each do |repo|
      repo_status(@local_config['project_directory'], repo)
    end
  end

  def clone
    puts "Cloning..."
    FileUtils::mkdir_p @local_config['project_directory']
    Dir.chdir @local_config['project_directory']
    @config['repos'].each do |repo|
      puts "Cloning #{repo['upstream']} to #{repo.keys.first}"
      g = Git.clone(repo['upstream'], repo.keys.first)
      g.branch(repo['ref']).checkout
    end
  end

  private

  MGIT_CONFIGURATION_ENV = 'MGIT_CONFIGURATION'.freeze

  def configuration_defined?
    if @config_dir.nil? || @config_dir.empty?
      false
    else
      true
    end
  end

  def read_config(config_file)
    YAML.load_file(config_file)
  end

  def dump_repo_config(repo)
    puts "\t\t#{repo.keys.first}"
    puts "\t\tUpstream url: #{repo['upstream']}"
    puts "\t\tDevelopment url: #{repo['dev']}"
    puts "\t\tGit reference: #{repo['ref']}"
    puts
  end

  def repo_status(project_dir, repo)
    working_dir = project_dir + repo.keys.first
    puts "Opening #{working_dir}"
    g = Git.open(working_dir, :log => Logger.new(STDOUT))
  end
end

program :name, 'mgit'
program :version, '0.0.1'
program :description, 'Multiple git repositories manager.'

command :dump_config do |c|
  c.syntax = 'mgit dump_config'
  c.description = 'Displays mgit configuration'
  c.action do ||
    mgit = MGit.new
    mgit.dump_config
  end
end

command :clone do |c|
  c.syntax = 'mgit clone'
  c.description = 'Clone all the repositories'
  c.action do ||
    mgit = MGit.new
    mgit.clone
  end
end


command :status do |c|
  c.syntax = 'mgit status'
  c.description = 'Status of every repository'
  c.action do ||
    mgit = MGit.new
    mgit.status
  end
end
