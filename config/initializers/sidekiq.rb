unless Rails.env.test?
  Sidekiq.configure_server do |config|
    config.redis = {url: Rails.application.credentials.redis.url.sidekiq}
  end

  Sidekiq.configure_client do |config|
    config.redis = {url: Rails.application.credentials.redis.url.sidekiq}
  end
end
