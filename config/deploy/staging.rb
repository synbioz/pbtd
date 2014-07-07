server 'pbtd.dev.synbioz.com', user: 'synbioz', roles: %w{web app db}

set :rails_env, 'staging'

set :branch, 'develop'

after 'deploy', 'copy_no_robots_file'
