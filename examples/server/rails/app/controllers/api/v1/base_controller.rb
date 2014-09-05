class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!
  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    render json: {error: exception.message}, status: 403
  end
end
