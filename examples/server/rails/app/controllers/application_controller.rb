class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ActionController::ImplicitRender
  include ActionController::Serialization
  include CanCan::ControllerAdditions

  before_action :validate_token
  before_action :configure_permitted_parameters, if: :devise_controller?

  serialization_scope :current_user

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    # devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    # devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end

  protected

  def current_identity
    @identity
  end

  def validate_token
    begin
      auth_header = request.headers['Authorization']
      token = auth_header.split(' ').last
      claim = JWT.decode(token, Rails.application.secrets.shared_secret)
      if !claim[0]['identity'].nil?
        @identity = Identity.find(claim[0]['identity']['id'])
      elsif !claim[0]['user'].nil?
        id = claim[0]['user']['id']
        user = User.find(id)
        env['warden'].set_user(user)
      end
    rescue JWT::DecodeError, NoMethodError
    end
  end

end
