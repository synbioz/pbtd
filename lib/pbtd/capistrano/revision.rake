namespace :remote do
  desc "Remote fetch git revision for current deploy"
  task :fetch_revision do
    on roles(:app) do |host|
      command = %W( ssh #{host.user}@#{host} -t )
      command << "cat #{current_path}/REVISION"
      system *command
    end
  end
end
