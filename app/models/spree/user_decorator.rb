Spree::User.class_eval do
  has_many :user_authentications

  devise :omniauthable

  def apply_omniauth(omniauth, authentication)
    if omniauth['provider'] == "facebook"
      self.email = omniauth['info']['email'] if email.blank?
    end

    #user_authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
    user_authentications << authentication
  end

  def password_required?
    (user_authentications.empty? || !password.blank?) && super
  end
end
