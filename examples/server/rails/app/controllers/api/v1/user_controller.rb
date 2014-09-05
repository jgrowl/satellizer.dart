class Api::V1::UserController < Api::V1::BaseController
  load_and_authorize_resource
  def profile
    render json: current_user
  end
end
