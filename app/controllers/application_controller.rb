class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :mini_profiler

  private
  def mini_profiler
    Rack::MiniProfiler.authorize_request
  end
end
