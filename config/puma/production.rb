#!/usr/bin/env puma

ROOT_PATH = '/var/www/pbtd'.freeze
SHRD_PATH = "#{ROOT_PATH}/shared".freeze
CURT_PATH = "#{ROOT_PATH}/current".freeze

# The directory to operate out of.
#
# The default is the current directory.

directory "#{ROOT_PATH}/current"

# Use an object or block as the rack application. This allows the
# config file to be the application itself.
#
# app do |env|
#   puts env
#
#   body = 'Hello, World!'
#
#   [200, { 'Content-Type' => 'text/plain', 'Content-Length' => body.length.to_s }, [body]]
# end

# Load “path” as a rackup file.
#
# The default is “config.ru”.
#
# rackup '/u/apps/lolcat/config.ru'

# Set the environment in which the rack's app will run. The value must be a string.
#
# The default is “development”.

environment 'production'

# Daemonize the server into the background. Highly suggest that
# this be combined with “pidfile” and “stdout_redirect”.
#
# The default is “false”.

daemonize true

# Store the pid of the server in the file at “path”.

pidfile "#{SHRD_PATH}/tmp/pids/puma.pid"

# Use “path” as the file to store the server info state. This is
# used by “pumactl” to query and control the server.

state_path "#{SHRD_PATH}/tmp/pids/puma.state"

# Redirect STDOUT and STDERR to files specified. The 3rd parameter
# (“append”) specifies whether the output is appended, the default is
# “false”.

stdout_redirect "#{SHRD_PATH}/log/puma.out.log", "#{SHRD_PATH}/log/puma.err.log", true

# Disable request logging.
#
# The default is “false”.
#
# quiet

# Configure “min” to be the minimum number of threads to use to answer
# requests and “max” the maximum.
#
# The default is “0, 16”.

threads 0, 16

# Bind the server to “url”. “tcp://”, “unix://” and “ssl://” are the only
# accepted protocols.
#
# The default is “tcp://0.0.0.0:9292”.
#
# bind 'tcp://0.0.0.0:9292'
# bind 'unix:///var/run/puma.sock'
# bind 'unix:///var/run/puma.sock?umask=0777'
# bind 'ssl://127.0.0.1:9292?key=path_to_key&cert=path_to_cert'

bind "unix://#{SHRD_PATH}/tmp/sockets/puma.sock"

# Instead of “bind 'ssl://127.0.0.1:9292?key=path_to_key&cert=path_to_cert'” you
# can also use the “ssl_bind” option.
#
# ssl_bind '127.0.0.1', '9292', { key: path_to_key, cert: path_to_cert }

# Code to run before doing a restart. This code should
# close log files, database connections, etc.
#
# This can be called multiple times to add code each time.
#
on_restart do
  puts 'On restart...'
  puts 'Refreshing Gemfile'
  ENV["BUNDLE_GEMFILE"] = "#{CURT_PATH}/Gemfile"
end

# Command to use to restart puma. This should be just how to
# load puma itself (ie. 'ruby -Ilib bin/puma'), not the arguments
# to puma, as those are the same as the original process.
#
# restart_command '/etc/init.d/puma restart prediction'

# === Cluster mode ===

# How many worker processes to run.
#
# The default is “0”.
#
# workers 2

# Code to run when a worker boots to setup the process before booting
# the app.
#
# This can be called multiple times to add hooks.
#
# on_worker_boot do
#   puts 'On worker boot...'
#
#   ActiveSupport.on_load(:active_record) do
#     ActiveRecord::Base.establish_connection
#   end
# end

# === Puma control rack application ===

# Start the puma control rack application on “url”. This application can
# be communicated with to control the main server. Additionally, you can
# provide an authentication token, so all requests to the control server
# will need to include that token as a query parameter. This allows for
# simple authentication.
#
# Check out https://github.com/puma/puma/blob/master/lib/puma/app/status.rb
# to see what the app has available.
#
# activate_control_app 'unix:///var/run/pumactl.sock'
# activate_control_app 'unix:///var/run/pumactl.sock', { auth_token: '12345' }
# activate_control_app 'unix:///var/run/pumactl.sock', { no_token: true }

activate_control_app "unix://#{SHRD_PATH}/tmp/sockets/pumactl.sock"
