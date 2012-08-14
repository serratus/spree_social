class Spree::UserAuthentication < ActiveRecord::Base
  attr_accessible :provider, :uid,  :auth_token, :expires_at, :expires
  belongs_to :user
end
