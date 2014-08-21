namespace :remote do
  desc "Remote fetch git revision for current deploy"
  task :fetch_revision do
    on roles(:app) do |host|
      Net::SSH.start(host.to_s, host.user.to_s) do |ssh|
        ssh.exec "tail -1 #{deploy_to}/revisions.log"
      end
    end
  end
end
