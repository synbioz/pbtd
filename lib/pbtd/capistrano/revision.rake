namespace :remote do
  desc "Remote fetch remote host"
  task :fetch_host do
    on roles(:app) do |host|
      print "#{host.to_s},#{host.user.to_s},#{deploy_to},#{current_path}"
    end
  end
end


