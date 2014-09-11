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
require 'pbtb/command'

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
    host, user, deploy_to, current_path = fetch_host_infos

    begin
      Net::SSH.start(host, user, keys: [SETTINGS['ssh_private_key']]) do |ssh|
        guard_command = Command.new.raw!("[ -f #{deploy_to}/current/REVISION ]")
        cat_command = Command.new.cat!("#{deploy_to}/current/REVISION")
        stdout, stderr = ssh.exec!(Command.and(guard_command, cat_command))
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
    host, user, deploy_to, current_path = fetch_host_infos
    version = ""

    begin
      Net::SSH.start(host, user, keys: [SETTINGS['ssh_private_key']]) do |ssh|
        version = ssh.exec!(Command.cd(current_path).raw!('~/.rbenv/bin/rbenv version'))
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
      bundle_install_command = Command.new.clean.cd(project_path).bundle_install!('deployment'),
      ssh_agent_command = Command.new.ssh_agent!
      Command.and(bundle_install_command, ssh_agent_command)
    end

    def fetch_host_command
      if cap_version < "3.0.0"
        Command.new.clean.cap!(self.name, '-Ff', "#{cap2_lib_path}/revision.rake", 'remote:fetch_host')
      else
        Command.new.clean.cap!(self.name, '-R', cap3_lib_path, 'remote:fetch_host')
      end
    end

    def fetch_host_infos
      cmd = Command.and(base_command, fetch_host_command)
      f = IO.popen(cmd)
      host_infos = f.readlines.last.split(',')
      f.close
      host_infos
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
