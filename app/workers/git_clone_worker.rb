class GitCloneWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  #
  # sidekiq process to clone the git repository into the app
  # @param project_id [Integer] [id of Project object]
  # @param default_branch=nil [String] [defaut git branch for project init clone]
  #
  # @return [String] [sidekiq job id]
  def perform(project_id, default_branch=nil)
    project = Project.find(project_id)
    project.worker.destroy if project.worker
    project.create_worker(job_id: self.jid, class_name: self.class.name)
    project.worker.running!
    project.save
    begin
      repo = Pbtd::GitRepository.new(project.repository_url)
      repo.clone(project.repo_name, default_branch)

      project.worker.success!
      repo.close
    rescue => e
      project.worker.fail_with!(e)
    end
  end
end
