namespace :remote do
  desc "Remote fetch git revision for current deploy"
  task :fetch_revision do
    on roles(:app) do |host|
      Net::SSH.start(host.to_s, host.user.to_s) do |ssh|
        ssh.exec "cat #{current_path}/REVISION"
      end
    end
  end
end
