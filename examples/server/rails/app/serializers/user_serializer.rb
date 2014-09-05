class UserSerializer < ActiveModel::Serializer
  # attributes :id, :role, :email, :username, :jwt, :can_update, :can_delete
  attributes :id, :role, :email, :username, :jwt
  has_many :identities
end
