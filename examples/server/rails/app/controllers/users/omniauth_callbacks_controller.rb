class Users::OmniauthCallbacksController < ApplicationController
  # skip_authorization_check

  def oauthio
    auth = request.env['omniauth.auth']
    # Find an identity here
    @identity = Identity.find_with_omniauth(auth)

    if @identity.nil?
      # If no identity was found, create a brand new one here
      @identity = Identity.create_with_omniauth(auth)
    end

    # session[:identity_id] = @identity.id
    jwt = JWT.encode({identity: {id: @identity.id}}, Rails.application.secrets.shared_secret)

    if signed_in?
      if @identity.user == current_user
        # User is signed in so they are trying to link an identity with their
        # account. But we found the identity and the user associated with it
        # is the current user. So the identity is already associated with
        # this user. So let's display an error message.
        msg = 'Already linked that account!'
        if params['format'] == 'json'
            respond_to do |format|
              format.json  {render json: {status: :signed_in, message: msg, user: @identity.user}}
              # format.json  {render json: {status: :signed_in, message: msg, user: {identities: @identity.user.identities}}}
            end
        else
          redirect_to root_url, notice: msg
        end

      else
        # The identity is not associated with the current_user so lets
        # associate the identity
        @identity.user = current_user
        @identity.save()
        msg = 'Successfully linked that account!'
        if params['format'] == 'json'
          respond_to do |format|
            format.json  {render json: {status: :account_linked, message: msg, user: {identities: @identity.user.identities}}}
          end
        else
          redirect_to root_url, notice: msg
        end
      end
    else
      if @identity.user.present?
        # The identity we found had a user associated with it so let's just log them in here
        # self.current_user = @identity.user
        msg = 'Signed in!'
        if params['format'] == 'json'
          respond_to do |format|
            format.json  {render json: {status: :signed_in, message: msg, user: @identity.user}}
          end
        else
          redirect_to root_url, notice: msg
        end
      else
        # No user associated with the identity so we need to create a new one
        msg = 'Please finish registering'
        if params['format'] == 'json'
          respond_to do |format|
            format.json  {render json: {status: :additional_info_required, message: msg,
                                        user: {nickname: auth['info']['nickname'], jwt: jwt}}}
          end
        else
          redirect_to new_user_url, notice: msg
        end
      end
    end
  end
end