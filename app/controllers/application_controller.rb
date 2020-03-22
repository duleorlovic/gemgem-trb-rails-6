class ApplicationController < ActionController::Base
  def tyrant
    Tyrant::Session.new request.env['warden']
  end
  helper_method :tyrant
end
