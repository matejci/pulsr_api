template = ERB.new File.new(File.join(Rails.root, 'config', 'redis.yml')).read
RedisConfig = YAML.load(template.result(binding)).fetch(Rails.env.to_s).symbolize_keys.merge(namespace: 'pulsr')

$redis_cache = case ENV['RAILS_ENV']
when 'development'
	# Redis.new(
	#           :host => RedisConfig[:redis_cache]['host'],
	#           :port => RedisConfig[:redis_cache]['port'],
	#           :db => RedisConfig[:redis_cache]['db'],
	#           :namespace => RedisConfig[:redis_cache]['namespace'])
	Redis.new(:url => ENV['REDIS_DEV_CACHE_PATH'])
when 'staging', 'production'
	Redis.new(:url => ENV['REDIS_CACHE_PATH'])
else
	nil
end
