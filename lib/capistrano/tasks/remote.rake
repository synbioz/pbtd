namespace :remote do
  desc "Remote console"
  task :console do
    on roles(:app) do |host|
      command = %W( ssh #{host.user}@#{host} -t )
      command << "source ~/.zshrc && cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} bundle exec rails console"
      system *command
    end
  end
  desc "Remote shell"
  task :shell do
    on roles(:app) do |host|
      command = %W( ssh #{host.user}@#{host} -t )
      command << "source ~/.zshrc && cd #{current_path} && bash --login"
      system *command
    end
  end
end
