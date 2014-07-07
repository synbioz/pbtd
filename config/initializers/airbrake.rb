Airbrake.configure do |config|
  config.api_key = '0379c59d659a4825d8c6bce227ed0b04'
  config.host    = 'errbit.synbioz.com'
  config.port    = 80
  config.secure  = config.port == 443
end
