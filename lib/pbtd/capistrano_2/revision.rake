namespace :remote do
  desc "Remote fetch remote host"
  task :fetch_host, :roles => :app do |host|
    print "#{host.roles[:app].servers.first.to_s},#{host.user.to_s},#{deploy_to},#{current_path}"
  end
end
