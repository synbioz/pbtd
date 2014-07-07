namespace :deploy do
  task :generate_version do
    on roles(:app) do
      revision = fetch(:current_revision)
      version_file = StringIO.new "#{`whoami`.strip}: #{revision} @ #{Time.now.strftime("%d-%m-%Y %H:%M:%S")}"
      upload! version_file, "#{release_path}/public/version.txt"
      execute :chmod, "a+r", "#{release_path}/public/version.txt"
    end
  end
end
