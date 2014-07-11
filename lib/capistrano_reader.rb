module Pbtd

  #
  # module for capistrano informations management
  #
  module Capistrano

    class Reader
      # Regex to find capistrano version in Gemfile.lock
      REGEX_VERSION = /capistrano\s\(([0-9.]*)\)/


      #
      # Constructor for read capistrano repository informations
      # @param repository_path [String] [path of capistrano project]
      #
      # @return [Reader]
      def initialize(repository_path)
        @path = repository_path
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
      end
    end
  end
end
