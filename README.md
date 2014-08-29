# Push Button To Deploy

## Repository configuration

The git repository uses the `git flow` scripts. This is the configuration found in `.git/config`:

```
[gitflow "branch"]
  master, develop
[gitflow "prefix"]
  feature = feature/
  release = release/
  hotfix = hotfix/
  support = support/
  versiontag =
```

The develop branch is `develop` and the production releases branch is `master`. **THIS IS NOT THE DEFAULT BEHAVIOUR OF GIT FLOW.**

## Database

The application uses postgresql as RDMS.

I recommends to create a specific user with limited rights on the database. For instance, I do not allow my users to create or remove databases.
Thus, you should create your development and testing databases manually.

## Test stack

The application uses RSpec as test framework. In development mode, Guard is used as a test triggerer.

The `fabrication` gem provides factories.

To play the test suite run : `bundle exec rspec`

To launch the guard test engine run: `bundle exec guard`


## Models

The application have four models :
* Project
  Configure name and repository url of project
* Location
  Manage application environments

* Deployment
  Manage deployments of differents locations
* Commit
  History of repository commits for locations and deployments

## Configuration

### requirements

The application require:

* redis
* libgit2
* openssl
* git
* sidekiq
* faye

### lib/pbtd/enable-ssh.sh

`lib/pbtd/enable-ssh.sh` manage ssh-agent for different shell command launched by application.
You must change path where you want to store `ssh-agent-socket`, `ssh-export-agent`, `ssh-agent.pid` and `pbtd_key`.
You must create ssh key `pbtd_key` in your prefered path.

```sh
 #!/bin/bash
start_agent() {
  ssh-agent -s -a /var/www/pbtd/shared/tmp/sockets/ssh-agent-socket > /var/www/pbtd/shared/tmp/ssh/ssh-export-agent
  . /var/www/pbtd/shared/tmp/ssh/ssh-export-agent
  echo $SSH_AGENT_PID > /var/www/pbtd/shared/tmp/pids/ssh-agent.pid
}

if ! [  -S /var/www/pbtd/shared/tmp/sockets/ssh-agent-socket ]  ; then start_agent; fi
if [ -z $SSH_AGENT_PID ] ; then . /var/www/pbtd/shared/tmp/ssh/ssh-export-agent; fi

ssh-add -l > /dev/null 2>&1
if [ $? -ne 0 ]; then
  ssh-add /var/www/pbtd/shared/tmp/ssh/pbtd_key > /dev/null 2>&1
fi
```

### config/settings.yml

`config/settings.yml` contains all configuration variables by environnment:

* `repositories_path` place where projects cloned are stored
* `faye_server` link to your faye server
* `default_branch` the default branch where application can get the capistrano configuration
* `ssh_agent_script` where enable-ssh.sh is stored

For other environments than staging and development:

* `ssh_public_key` place where ssh public key was created for application
* `ssh_private_key` place where ssh private was created for application
* `basic_auth_user` user name for basic authentification
* `basic_auth_password` password for basic authentification

### capistrano environments requirement

Pbtd require some things for capistrano environments files:

* server
* rails_env variable
* branch variable

example with `config/deploy/staging.rb`:

```ruby
server 'pbtd.dev.synbioz.com', user: 'synbioz', roles: %w{web app db}

set :rails_env, 'staging'

set :branch, 'develop'
```

## Launch project in development environment

launch these process:

```
redis-server
sidekiq
rackup faye.ru -E production -s thin -p 9292
rails s puma
```
In development and test environment you must add the key you use to connect your git repository and for remote servers used to deploy your applications to the ssh-agent.
Running in terminal `ssh-add`

