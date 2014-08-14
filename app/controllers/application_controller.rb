class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  http_basic_authenticate_with realm: 'Pbtd access', name: SETTINGS['basic_auth_user'], password: SETTINGS['basic_auth_password'], if: lambda { !(Rails.env.test? || Rails.env.development?) }
end
