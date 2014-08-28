# == Schema Information
#
# Table name: locations
#
#  id              :integer          not null, primary key
#  project_id      :integer
#  name            :string(255)
#  branch          :string(255)
#  application_url :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  distance        :integer
#  worker_id       :integer
#

class Location < ActiveRecord::Base
  has_many :deployments, dependent: :destroy
  has_many :commits, dependent: :destroy

  belongs_to :project
  belongs_to :worker, dependent: :destroy

  validates_presence_of :name, :branch, :application_url, :project

  after_commit :update_distance, on: :create

  #
  # deploy current location to remote server
  #
  # @return [void]
  def deploy
    DeployWorker.perform_async(self.id)
  end

  #
  # get current commit sha on remote server
  #
  # @return [String] [git commit sha]
  def get_current_release_commit
    cap_lib_path = Rails.root.join('lib', 'pbtd', 'capistrano')
    cap_2_lib_path = Rails.root.join('lib', 'pbtd', 'capistrano_2')
    project_path = File.join(SETTINGS["repositories_path"], self.project.repo_name)

    cap_version = Pbtd::CapistranoReader.new(self.project.repo_name).version

    sha = nil

    # Bundle install cannot install headers for specific gems (ex: 'sqlite')
    # Please install it on remote servers
    if cap_version < "3.0.0"
      sha = Bundler.with_clean_env do
        `cd #{project_path} 2> /dev/null && bundle install 2> /dev/null && #{SETTINGS["ssh_agent_script"]} bundle exec cap #{self.name} -Ff #{cap_2_lib_path}/revision.rake remote:fetch_revision`
      end
    else
      sha = Bundler.with_clean_env do
        `cd #{project_path} 2> /dev/null && bundle install 2> /dev/null && #{SETTINGS["ssh_agent_script"]} bundle exec cap #{self.name} -R #{cap_lib_path} remote:fetch_revision`
      end
    end

    sha = sha.lines.last.strip

    if sha.empty? || !(/(\A\S*\z)/.match(sha))
      logger.debug "the commit oid cannot be parsed"
      raise "cannot fetch remote host #{self.application_url}"
    else
      return sha
    end
  end

  #
  # check if ruby version on remote server is installed
  #
  # @return [void]
  def check_ruby_version
    cap_lib_path = Rails.root.join('lib', 'pbtd', 'capistrano')
    cap_2_lib_path = Rails.root.join('lib', 'pbtd', 'capistrano_2')
    project_path = File.join(SETTINGS["repositories_path"], self.project.repo_name)

    version = nil

    if cap_version < "3.0.0"
      version = Bundler.with_clean_env do
        `cd #{project_path} 2> /dev/null && bundle install 2> /dev/null && #{SETTINGS["ssh_agent_script"]} bundle exec cap #{self.name} -Ff #{cap_2_lib_path}/revision.rake remote:check_ruby_version`
      end
    else
      version = Bundler.with_clean_env do
      `cd #{project_path} 2> /dev/null && bundle install 2> /dev/null && #{SETTINGS["ssh_agent_script"]} bundle exec cap #{self.name} -R #{cap_lib_path} remote:check_ruby_version`
      end
    end



    version = version.lines.last.strip

    if version.include? "is not installed"
      logger.debug "the ruby version is not installed on remote server"
      raise "The ruby version is not installed on remote server"
    end
  end


  #
  # fetch distance from remote server for location
  #
  # @return [String] [Sidekiq job_id]
  def update_distance
    DistanceWorker.perform_async(self.id)
  end
end
