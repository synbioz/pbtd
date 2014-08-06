lock '3.2.1'

set :user, "synbioz"
set :application, 'pbtd'
set :repo_url, 'git@git.synbioz.com:synbioz/pbtd.git'

set :deploy_to, '/var/www/pbtd'

# Default value
# set :scm, :git
# set :format, :dot

set :log_level, :info

# Default value for :pty is false
# set :pty, true

set :ssh_options, { forward_agent: true }

set :linked_files, %w{
  config/database.yml
  config/secrets.yml
}

set :linked_dirs, %w{
  log
  tmp/pids
  tmp/cache
  tmp/sockets
  vendor/bundle
  public/system
}

set :default_env, { path: "~/.rbenv/bin:~/.rbenv/shims:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

#
# Configure extensions
#

set :bundle_flags, "--quiet"

set :rbenv_type, :user
set :rbenv_ruby, '2.1.2'

set :puma_conf, -> { File.join(release_path, 'config', 'puma', "#{fetch(:stage)}.rb") }

# Do not perform the puma's check task because the config file
# is in the source tree. The check method will try to upload
# a config file but will never succeed.
Rake::Task['puma:check'].clear

set :hipchat_token, "3a2ffef748546e98d6382682e9eddc"
set :hipchat_room_name, "deploy"
set :hipchat_announce, false

# content of your recipe faye
set :faye_pid, "#{deploy_to}/shared/pids/faye.pid"
set :faye_config, "#{deploy_to}/current/faye.ru"

#
# Customize deploy
#

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      Rake::Task["puma:restart"].invoke
    end
  end

  after :publishing, :restart

  desc 'Runs rake db:seed'
  task :seed => [:set_rails_env] do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:seed"
        end
      end
    end
  end

  after :migrate, :seed

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end



after "deploy", "deploy:generate_version"
after "deploy:finished", "airbrake:deploy"
