class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session,
      if: Proc.new { |c| c.request.format =~ %r{application/json} }

  layout :layout_by_resource

  protected

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
end
