task :copy_no_robots_file do
  on roles(:app) do |host|
    execute :cp, "#{release_path}/public/no_robots.txt", "#{release_path}/public/robots.txt"
  end
end
