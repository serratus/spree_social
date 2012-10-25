class Spree::UserAuthentication < ActiveRecord::Base
  
  attr_accessible :provider, :uid,  :auth_token, :expires_at, :expires
  belongs_to :user
  
  scope :active, (lambda do 
    where("expires_at > ? OR expires = ?", Time.now, false)
  end)
  
  def self.facebook
    where(provider: "facebook").active
  end
  
  def self.instagram
    where(provider: "instagram").active
  end
end
