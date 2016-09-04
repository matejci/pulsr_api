require 'dotenv'
Dotenv.load

set :application, 'pulsr_api'
set :repo_url, 'git@github.com:sd2labsGlobal/pulsr_backend_main.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, "/home/deploy/www/#{fetch(:application)}"
set :scm, :git

# Whenever integration with different environments
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

set :whenever_roles, ["data_import", "eventful_api", "twitter_realtime", "recommendation", "recommendation_zoning"]

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', '.env')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/import', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'unicorn:legacy_restart'
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  task :seed do
   puts "\n=== Seeding Database ===\n"
   on primary :db do
    within current_path do
      with rails_env: fetch(:stage) do
        execute :rake, 'db:seed'
      end
    end
   end
  end

  after :finishing, 'deploy:cleanup'

  after 'deploy:publishing', 'deploy:restart'
  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'

  after :finished, 'opsworks'
end


# Add this to your /etc/sudoers file in order to allow the user
# deploy to control the Sidekiq worker daemon via Upstart:
# Add this at the end of the file to override regular for this user
#   deploy ALL = (root) NOPASSWD: /sbin/start sidekiq, /sbin/stop sidekiq, /sbin/status sidekiq
# namespace :sidekiq do
#   desc 'Start the sidekiq workers via Upstart'
#   task :start do
#     on roles(:twitter_realtime), in: :sequence, wait: 5 do
#       sudo 'start sidekiq'
#     end
#   end

#   desc 'Stop the sidekiq workers via Upstart'
#   task :stop do
#     on roles(:twitter_realtime), in: :sequence, wait: 5 do
#       sudo 'stop sidekiq || true'
#     end
#   end

#   desc 'Restart the sidekiq workers via Upstart'
#   task :restart do
#     on roles(:twitter_realtime), in: :sequence, wait: 5 do
#       sudo 'stop sidekiq || true'
#       sudo 'start sidekiq'
#     end
#   end

#   desc "Quiet sidekiq (stop accepting new work)"
#   task :quiet do
#     pid_file       = "#{current_path}/tmp/pids/sidekiq.pid"
#     sidekiqctl_cmd = "bundle exec sidekiqctl"
#     run "if [ -d #{current_path} ] && [ -f #{pid_file} ] && kill -0 `cat #{pid_file}`> /dev/null 2>&1; then cd #{current_path} && #{sidekiqctl_cmd} quiet #{pid_file} ; else echo 'Sidekiq is not running'; fi"
#   end
# end

# before 'deploy:update_code', 'sidekiq:quiet'
# after  'deploy:stop',        'sidekiq:stop'
# after  'deploy:start',       'sidekiq:start'
# before 'deploy:restart',     'sidekiq:restart'

namespace :rpush do
  desc 'Start the push via Upstart'
  task :start do
    on roles(:twitter_realtime), in: :sequence, wait: 5 do
      sudo 'start push'
    end
  end

  desc 'Stop the push via Upstart'
  task :stop do
    on roles(:twitter_realtime), in: :sequence, wait: 5 do
      sudo 'stop push || true'
    end
  end

  desc 'Restart the push via Upstart'
  task :restart do
    on roles(:twitter_realtime), in: :sequence, wait: 5 do
      # sudo 'reload push'
    end
  end
end

before 'deploy:restart', 'rpush:restart'

# Copy all the upstart processes on update
namespace :upstart do
  desc 'Generate and upload Upstard configs for daemons needed by the app'
  task :update_configs do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      upstart_config_files = File.expand_path('../upstart/*.conf.erb', __FILE__)
      upstart_root         = '/etc/init'

      Dir[upstart_config_files].each do |upstart_config_file|
        config = ERB.new(IO.read(upstart_config_file)).result(binding)
        path   = "#{upstart_root}/#{File.basename upstart_config_file, '.erb'}"

        put config, path
      end
    end
  end
end

# after 'deploy:update_code', 'upstart:update_configs'
