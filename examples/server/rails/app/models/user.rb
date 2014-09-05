class User < ActiveRecord::Base
  has_many :identities
  before_create :set_default_role

  def as_json(options={})
    super.as_json(options).merge({jwt: jwt, identities: identities})
  end

  def jwt
    JWT.encode({user: {id: id}}, Rails.application.secrets.shared_secret);
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :omniauthable,
         :omniauth_providers => [:oauthio]

  private
  def set_default_role
    self.role ||= 'registered'
  end

end
