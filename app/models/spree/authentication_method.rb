class Spree::AuthenticationMethod < ActiveRecord::Base
  attr_accessible :provider, :api_key, :api_secret, :environment, :active

  scope :active, where(:environment => ::Rails.env).where(active: true)

  def self.active_authentication_methods?
    found = false
    where(:environment => ::Rails.env).each do |method|
      if method.active
        found = true
      end
    end
    return found
  end
  
  def self.facebook
    scoped.active.where(provider: 'facebook').first
  end
  
  def user_connected?(user)
    user.user_authentications.any? {|ua| ua.provider == self.provider}
  end
  
end
