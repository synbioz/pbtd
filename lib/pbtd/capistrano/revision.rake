namespace :remote do
  desc "Remote fetch git revision for current deploy"
  task :fetch_revision do
    on roles(:app) do |host|
      Net::SSH.start(host.to_s, host.user.to_s) do |ssh|
        sha = nil

        stderr, stdout = ssh.exec!("[ -f #{deploy_to}/current/REVISION ] && cat #{deploy_to}/current/REVISION")

        sha = stdout.strip if stdout

        unless sha
          output = ssh.exec!("tail -1 #{deploy_to}/revisions.log")
          sha = /\(at.(\w*)\)/.match(output)[1] if /\(at.(\w*)\)/.match(output)
        end

        puts sha
      end
    end
  end
end



