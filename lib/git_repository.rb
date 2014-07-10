module Pbtd

    class GitRepository
      attr_reader :repository_url, :username
      attr_accessor :rugged_repository

      def initialize(&repo_url)
        unless repo_url.nil?
          @repository_url = repo_url
          @username = repo_url.split('@').first
        end
      end

      def open(repo_name)
        @rugged_repository = Rugged::Repository.new(in_path(repo_name))
      end

      def clone(name_repository)
        @rugged_repository = Rugged::Repository.clone_at(repository_url, in_path(name_repository), credentials: credentials, bare: true)
      end

      def remote_branches
        rugged_repository.branches.each_name(:remote).sort
      end

      def last_commit(branch_name)
        rugged_repository.branches[branch_name].target
      end

      def fetch
        remote = rugged_repository.remotes['origin']

        @repository_url = remote.url
        @username = @repository_url.split('@').first

        remote.fetch(credentials: credentials)
      end

      private
        def in_path(name_repository)
          SETTINGS["repositories_path"] + '/' + name_repository
        end

        def credentials
          Rugged::Credentials::SshKeyFromAgent.new(username: @username)
        end
    end
end
