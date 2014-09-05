class RegistrationsController < Devise::RegistrationsController
  respond_to :json
  def create
    if @identity && params[:user][:password].nil?
      params[:user][:password] = Devise.friendly_token.first(8)
    end

    super

    if @identity
      @identity.user_id = @user.id
      @identity.save
    end
  end
end
