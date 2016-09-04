app_name = "PulsrAPI"
project_dir = "/home/deploy/#{app_name}"
root = "#{project_dir}/app"
shared_dir = "#{project_dir}/shared"
working_directory root

pid "#{project_dir}/tmp/pids/unicorn.pid"

stderr_path "#{project_dir}/log/unicorn.log"
stdout_path "#{project_dir}/log/unicorn.log"

worker_processes Integer(ENV['WEB_CONCURRENCY'] || 2)
timeout 30
preload_app true

# listen "/tmp/unicorn.#{app_name}.sock", backlog: 64
listen "#{shared_dir}/tmp/sockets/unicorn.sock", backlog: 64

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

# Force the bundler gemfile environment variable to
# reference the capistrano "current" symlink
before_exec do |_|
  ENV['BUNDLE_GEMFILE'] = File.join(root, 'Gemfile')
end
