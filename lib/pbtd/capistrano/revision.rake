namespace :remote do
  desc "Remote fetch git revision for current deploy"
  task :fetch_revision do
    on roles(:app) do |host|
      Net::SSH.start(host.to_s, host.user.to_s, keys: ["/var/www/pbtd/shared/tmp/ssh/pbtd_key"]) do |ssh|
        ssh.exec "cat #{current_path}/REVISION"
      end
    end
  end
end
