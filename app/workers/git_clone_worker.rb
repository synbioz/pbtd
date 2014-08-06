class GitCloneWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(project_id, default_branch)
    project = Project.find(project_id)
    project.worker.destroy if project.worker
    project.worker = Worker.create(job_id: self.jid, class_name: self.class.name)
    project.worker.running!
    project.save

    begin
      clone(project, default_branch)
      project.worker.success!
    rescue => e
      project.worker.error_class_name = e.class.name
      project.worker.error_message = e.message
      project.worker.failure!
    end
  end

  def clone(project, default_branch)
    repo = Pbtd::GitRepository.new(project.repository_url)
    repo.clone(project.repo_name, default_branch)

    repo.close
  end
end
