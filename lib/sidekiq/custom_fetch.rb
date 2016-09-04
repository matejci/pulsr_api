require 'sidekiq'
require 'sidekiq/fetch'

module Sidekiq
  class CustomFetch < Sidekiq::BasicFetch
    TIMEOUT = 1

    def initialize(options)
      @strictly_ordered_queues = !!options[:strict]
      @queues = options[:queues].map { |q| "queue:#{q}" }
      @unique_queues = @queues.uniq
    end

    def queues_cmd
      queues = @strictly_ordered_queues ? @unique_queues.dup : process_queues.shuffle.uniq
      queues << Sidekiq::CustomFetch::TIMEOUT
      queues
    end

    def process_unique_queues
      clean_processed_queues(@unique_queues)
    end

    def process_queues
      clean_processed_queues(@queues)
    end

    def clean_processed_queues(queue)
      temp_queue = queue.dup
      temp_queue.delete("queue:#{RateLimiter::INSTAGRAM_QUEUE}") if RateLimiter.instagram_limited?
      temp_queue.delete("queue:#{RateLimiter::SEARCH_TWITTER_QUEUE}") if RateLimiter.twitter_user_search_limited?
      temp_queue
    end
  end
end