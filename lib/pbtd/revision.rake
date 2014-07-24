namespace :remote do
  desc "Fetch commit revision for current release"
  task :fetch_revision do
    on roles(:app) do |host|
      command = %W( ssh #{host.user}@#{host} -t )
      command << "cat #{current_path}/REVISION"
      system *command
    end
  end
end
