class ApplicationController < ActionController::API
  include ErrorHandling
  include Pundit::Authorization
  include Authenticable
  rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found!

end
