class GitCloneWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(project_id, default_branch=nil)
    project = Project.find(project_id)
    project.worker.destroy if project.worker
    puts "errors"
    puts project.inspect
    puts default_branch.inspect
    project.worker = Worker.create(job_id: self.jid, class_name: self.class.name)
    project.worker.running!
    project.save

    begin
      repo = Pbtd::GitRepository.new(project.repository_url)
      repo.clone(project.repo_name, default_branch)

      project.worker.success!
    rescue => e
      project.worker.error_class_name = e.class.name
      project.worker.error_message = e.message
      project.worker.failure!
    ensure
      repo.close
    end
  end
end
