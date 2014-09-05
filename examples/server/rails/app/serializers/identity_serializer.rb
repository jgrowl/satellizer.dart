class IdentitySerializer < ActiveModel::Serializer
  attributes :provider, :uid
end
