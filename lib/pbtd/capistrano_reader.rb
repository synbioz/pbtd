module Pbtd

  #
  # Pbtd::CapistranoReader permit read capistrano configuration files
  #
  #
  class CapistranoReader
    # Regex to find capistrano version in Gemfile.lock
    REGEX_VERSION = /capistrano\s\(([0-9.]*)\)/
    # Regex to find branch in environment file
    REGEX_BRANCH = /:branch,\s*['"]([\w\-\_\/]*)['"]/
    # Regex to find url of environment
    REGEX_URL = /server\s['"]([a-z0-9.\-]*)['"]/
    # Regex to find url of environment from role web
    REGEX_URL_FROM_ROLE = /:web,\s['"]([a-z0-9.\-]*)['"]/

    #
    # Constructor for read capistrano repository informations
    # @param repository_name [String] [path of capistrano project]
    #
    # @return [Reader]
    def initialize(repository_name)
      @path = in_path(repository_name)
    end


    #
    # return capistrano environments name (ex: 'staging' )
    #
    # @return [Array]
    def environments
      env_path = File.join(@path, "config/deploy/*.rb")
      Dir[env_path].map { |path| File.basename(path, ".*") }
    end


    #
    # return capistrano version of repository
    # find version in Gemfile.lock of repository
    # @return [String]
    def version
      content = File.read(File.join(@path, 'Gemfile.lock'))
      content.match(REGEX_VERSION)[1]
    rescue
      raise Pbtd::Error::FileNotFound, "Your Gemfile.lock not found for this environment"
    end

    #
    # return git branch of capistrano environment
    # @param environment [String] [name of capistrano environment]
    #
    # @return [String] [git branch name]
    def branch(environment)
      env_path = File.join(@path, "config/deploy/#{environment}.rb")
      content = File.read(env_path)
      content.match(REGEX_BRANCH)[1]
    end


    #
    # return url server of capistrano environment
    # @param environment [String] [name of capistrano environment]
    #
    # @return [String] [environment server url]
    def url(environment)
      env_path = File.join(@path, "config/deploy/#{environment}.rb")
      content = File.read(env_path)
      content.match(REGEX_URL) ? content.match(REGEX_URL)[1] : content.match(REGEX_URL_FROM_ROLE)[1]
    end

    private
    #
    # set path where repository is stored
    # @param repository_name [String] [folder repository name]
    #
    # @return [String]
    def in_path(repository_name)
      File.join(SETTINGS["repositories_path"], repository_name)
    end
  end

  #
  # Custom Errors
  #
  module Error
    exceptions = %w[ FileNotFound ]
    # Create empty empty class from exceptions array
    exceptions.each { |e| const_set(e, Class.new(StandardError)) }
  end
end
