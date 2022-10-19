class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  add_flash_types :info, :error, :success

  rescue_from ActionController::Redirecting::UnsafeRedirectError do
    redirect_to root
  end
end
