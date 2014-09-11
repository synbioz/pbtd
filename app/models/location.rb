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
require 'net/ssh'

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
    # Bundle install cannot install headers for specific gems (ex: 'sqlite')
    # Please install it on remote servers
    if cap_version < "3.0.0"
      cmd = base_command + "#{clean_env} bundle exec cap #{self.name} -Ff #{cap2_lib_path}/revision.rake remote:fetch_host"
    else
      cmd = base_command + "#{clean_env} bundle exec cap #{self.name} -R #{cap3_lib_path} remote:fetch_host"
    end

    f = IO.popen(cmd)
    host = f.readlines.last.split(',')
    f.close
    sha = ""

    begin
      Net::SSH.start(host.first, host[1], keys: [SETTINGS['ssh_private_key']]) do |ssh|
        deploy_to = host[2]

        stdout, stderr = ssh.exec!("[ -f #{deploy_to}/current/REVISION ] && cat #{deploy_to}/current/REVISION")
        sha = stdout.strip if stdout

        if sha.empty?
          output = ssh.exec!("tail -1 #{deploy_to}/revisions.log")
          sha = /\(at.(\w*)\)/.match(output)[1] if /\(at.(\w*)\)/.match(output)
        end
      end
    rescue
    end

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
    if cap_version < "3.0.0"
      cmd = base_command + "#{clean_env} bundle exec cap #{self.name} -Ff #{cap2_lib_path}/revision.rake remote:fetch_host"
    else
      cmd = base_command + "#{clean_env} bundle exec cap #{self.name} -R #{cap3_lib_path} remote:fetch_host"
    end

    f = IO.popen(cmd)
    host = f.readlines.last.split(',')
    f.close

    version = ""

    begin
      Net::SSH.start(host.first, host[1], keys: [SETTINGS['ssh_private_key']]) do |ssh|
        current_path = host.last

        version = ssh.exec!("cd #{current_path} && ~/.rbenv/bin/rbenv version")
      end
    rescue
      logger.debug "the commit oid cannot be parsed"
      raise "cannot fetch remote host #{self.application_url}"
    end

    if version.empty? || version.include?("is not installed")
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

  #
  # catch the capistrano version of the project location
  #
  # @return [String] [Capistrano version]
  def cap_version
    Pbtd::CapistranoReader.new(self.project.repo_name).version
  end

  private

    #
    # command to cd in repository directory && launch bundle install && init ssh agent
    #
    # @return [String] [command shell linux]
    def base_command
      project_path = File.join(SETTINGS["repositories_path"], self.project.repo_name)

      "cd #{project_path} 2> /dev/null && #{clean_env} bundle install --deployment 2> /dev/null && #{SETTINGS['ssh_agent_script']} "
    end

    #
    # linux shell command to clean the env variable
    #
    # @return [String] [command shell linux]
    def clean_env
      "env -i HOME=$HOME LC_CTYPE=${LC_ALL:-${LC_CTYPE:-$LANG}} PATH=$PATH USER=$USER SSH_AUTH_SOCK=$SSH_AUTH_SOCK SSH_AGENT_PID=$SSH_AGENT_PID"
    end

    #
    # path to the capistrano 3 custom task
    #
    # @return [Path]
    def cap3_lib_path
      Rails.root.join('lib', 'pbtd', 'capistrano')
    end

    #
    # path to the capistrano 2 custom task
    #
    # @return [Path]
    def cap2_lib_path
      Rails.root.join('lib', 'pbtd', 'capistrano_2')
    end
end
