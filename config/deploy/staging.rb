set :stage, :staging
set :branch, "staging"

set :access_key_id, ENV['AWS_OPSWORKS_ACCESS_KEY_ID']
set :secret_access_key, ENV['AWS_OPSWORKS_SECRET_ACCESS_KEY']
set :stack_id, '65167320-6610-4e93-beb5-8167dcf599a3'
set :app_id, '1ae29993-61b2-4a05-aca2-59555719814e'

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# role :app, %w{deploy@example.com}
# role :web, %w{deploy@example.com}
# role :db,  %w{deploy@example.com}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a hash can be used to set
# extended properties on the server.
set :whenever_roles, ["data_import", "eventful_api", "twitter_realtime"]

server '52.2.55.95', user: 'deploy', roles: %w{twitter_realtime recommendation_zoning}
server '52.0.138.96', user: 'deploy', roles: %w{recommendation factual_api eventful_api data_import}
server '52.4.100.228', user: 'deploy', roles: %w{web app db}


# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
# and/or per server
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# setting per server overrides global ssh_options

# fetch(:default_env).merge!(rails_env: :staging)
