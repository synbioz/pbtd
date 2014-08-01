class GitCloneWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(project_id)
    project = Project.find(project_id)
    project.worker.destroy if project.worker
    project.worker = Worker.create(job_id: self.jid, class_name: self.class.name)
    project.worker.running!
    project.save

    begin
      clone(project)
      project.worker.success!
    rescue => e
      project.worker.error_class_name = e.class.name
      project.worker.error_message = e.message
      project.worker.failure!
      raise e
    end
  end

  def clone(project)
    repo = Pbtd::GitRepository.new(project.repository_url)
    repo.clone(project.name)

    repo.close
  end
end
