module Pbtd

  class Reader
    REGEX_VERSION = /capistrano\s\(([0-9.]*)\)/
    attr_reader :repository_name, :capistrano_version

    def initialize(repository_name)
      @repository_name = repository_name
    end

    def capistrano_version
      content_file = File.read(gemfile_lock_path)
      @version = REGEX_VERSION.match(content_file)[1]
    end

    def capistrano_3?
      @version[0].to_i.eql?(3)
    end

    def capistrano_2?
      @version[0].to_i.eql?(2)
    end

    private

      def capistrano_path
        File.join(SETTINGS['repositories_path'], repository_name, 'config', 'deploy.rb')
      end

      def gemfile_lock_path
        File.join(SETTINGS['repositories_path'], repository_name, 'Gemfile.lock')
      end
  end
end
