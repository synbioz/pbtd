#
# Push Button To Deploy manage git repository
#
module Pbtd

    #
    # Pbtd::GitRepository is the class that permit to manage
    # git repository through 'rugged' gem
    #
    class GitRepository
      # @return [String]
      attr_reader :repository_url, :username
      # @return [Rugged::Repository]
      attr_accessor :rugged_repository

      #
      # Initializer for Pbtd::GitRepository class with optional git repository url
      # only SSH connection was implemented.
      # Syntax supported like : "user@domain:repository.git"
      #
      # @param repo_url [String] [git repository url, if blank it initialize empty Pbtd::GitRepository]
      #
      # @return [Pbtd::GitRepository]
      def initialize(repo_url=nil)
        unless repo_url.blank?
          @repository_url = repo_url
          @username = repo_url.split('@').first
        end
      end

      #
      # Check if git repository exist in local
      # @param repository_name [String] [folder name for cloned repository]
      #
      # @return [Boolean]
      def self.exist?(repository_name)
        Dir.exist?(GitRepository.in_path(repository_name))
      end

      #
      # Open existing and already cloned git repository
      # @param repo_name [String] [repository folder name]
      #
      # @return [Rugged::Repository]
      def open(repository_name)
        raise Pbtd::Error::FolderNotExist, "git repository not exist in local, please clone it" unless GitRepository.exist?(repository_name)
        @rugged_repository = Rugged::Repository.new(GitRepository.in_path(repository_name))
      end

      #
      # Clone a previous initialized Pbtd::GitRepository if
      # it has repository_url and username setted.
      # @param repository_name [String] [folder name for cloned repository]
      #
      # @return [Rugged::Repository]
      def clone(repository_name)
        raise Pbtd::Error::FolderAlreadyExist, "git repository already exist in local: #{GitRepository.in_path(repository_name)}" if GitRepository.exist?(repository_name)
        begin
          @rugged_repository = Rugged::Repository.clone_at(repository_url, GitRepository.in_path(repository_name), credentials: credentials)
          self.checkout(SETTINGS['default_branch'])
        rescue Rugged::OSError
          raise Pbtd::Error::Network, "Network is unreachable"
        rescue Rugged::NetworkError
          raise Pbtd::Error::GitRepositoryNotFound, "can't found your git repository"
        end
      end

      #
      # Return remote branches of the repository
      #
      # @return [Array] [array of branches name]
      def remote_branches
        rugged_repository.branches.each_name(:remote).sort
      end

      #
      # get the last commit of branch
      # @param branch_name [String] [branch name]
      #
      # @return [Rugged::Commit]
      def last_commit(branch_name)
        rugged_repository.branches[branch_name].target
      end

      #
      # `git fetch` repository
      #
      # @return [Integer] [number of git total deltas]
      def fetch
        remote = rugged_repository.remotes['origin']

        @repository_url = remote.url
        @username = @repository_url.split('@').first

        remote.fetch(credentials: credentials)[:total_deltas]
      rescue => e
        raise e
      end

      #
      # get number of commits between local branch and commit sha
      # @param branch_name [String] [local branch name]
      #
      # @return [Integer] [number of commits]
      def get_behind(branch_name, commit_sha)
        local_commit = last_commit(remote_branch_from_local(branch_name))
        remote_commit = rugged_repository.lookup(commit_sha)

        rugged_repository.ahead_behind(remote_commit, local_commit).first
      end

      #
      # Merge the previously fetched remote branch to your local branch
      # @param branch_name [String] [local branch name]
      #
      # @return [Rugged::Reference]
      def merge(branch_name)
        remote_commit = last_commit(remote_branch_from_local(branch_name))

        rugged_repository.references.update(rugged_repository.head, remote_commit.oid)
      end

      #
      # Checkout branch of git repository
      # @param branch_name [String] [branch name]
      #
      # @return [Rugged::Reference]
      def checkout(branch_name)
        local_branches = rugged_repository.branches.each_name.to_a
        if !local_branches.include?(branch_name) && self.remote_branch_from_local(branch_name)
          rugged_repository.branches.create(branch_name, self.remote_branch_from_local(branch_name))
        end
        rugged_repository.checkout(branch_name)
      end

      #
      # find remote branch name from local branch name
      # @param branch_name [String] [local branch name]
      #
      # @return [String]
      def remote_branch_from_local(branch_name)
        remote_branches.find { |x| x.ends_with?(branch_name) }
      end

      #
      # close the repository object
      #
      # @return [void]
      def close
        rugged_repository.close
      end

      private
        #
        # set path where repository is stored
        # @param repository_name [String] [folder repository name]
        #
        # @return [String]
        def self.in_path(repository_name)
          File.join(SETTINGS["repositories_path"], repository_name)
        end

        #
        # use Rugged::Credentials::SshKeyFromAgent for create ssh credentials for user
        #
        # @return [Rugged::Credentials::SshKeyFromAgent]
        def credentials
          Rugged::Credentials::SshKeyFromAgent.new(username: username)
        end
    end

    #
    # Custom Errors
    #
    module Error
      exceptions = %w[ GitRepositoryNotFound Network FolderAlreadyExist FolderNotExist ]
      # Create empty empty class from exceptions array
      exceptions.each { |e| const_set(e, Class.new(StandardError)) }
    end
end
