Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://127.0.0.1:6379/12', namespace: 'pbtd' }
  config.error_handlers << Proc.new { |ex,ctx_hash| Airbrake.notify_or_ignore(ex, ctx_hash) }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://127.0.0.1:6379/12', namespace: 'pbtd' }
end
