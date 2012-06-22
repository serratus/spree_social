Spree::UserRegistrationsController.class_eval do
  def create
    super
    session[:omniauth] = nil unless @user.new_record?
  end

  private

  def build_resource(*args)
    super
    if session[:omniauth]
      authentication = Spree::UserAuthentication.find_by_provider_and_uid(session[:omniauth]['provider'], session[:omniauth]['uid'])
      @user.apply_omniauth(session[:omniauth], authentication)
      @user.valid?
      @user
    end
  end
end
