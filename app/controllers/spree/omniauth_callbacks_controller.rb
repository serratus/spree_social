class Spree::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Spree::Core::CurrentOrder
  include Spree::Core::ControllerHelpers

  def self.provides_callback_for(*providers)
    providers.each do |provider|
      class_eval %Q{
        def #{provider}
          if request.env["omniauth.error"].present?
            Rails.logger.info "omniauth.error"
            flash[:error] = t("devise.omniauth_callbacks.failure", :kind => auth_hash['provider'], :reason => t(:user_was_not_valid))
            render 'spree/social/social_redirect', :layout => false
            return
          end
          
          # find authentications
          authentication = Spree::UserAuthentication.find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid'])

          if auth_hash['provider'] == 'facebook'
            if !authentication.nil? || !SpreeClay::Config[:pre_auth_required]
              if !authentication.user.nil? # already signed up
                flash[:notice] = "Signed in successfully"
                sign_in :user, authentication.user
                @redirect_url = session[:return_to] || root_url
                render 'spree/social/social_redirect', :layout => false
                return
              else # not yet signed up
                user = Spree::User.new 
                user.apply_omniauth(auth_hash, authentication)

                session[:omniauth] = auth_hash.except('extra')
                flash[:notice] = t(:one_more_step, :kind => auth_hash['provider'].capitalize)
                flash[:error] = nil
                @redirect_url = new_user_registration_url
                render 'spree/social/social_redirect', :layout => false
                return
              end
            else
              flash[:notice] = "This is a private beta, please stand by"
              @redirect_url = spree.root_url
              render 'spree/social/social_redirect', :layout => false
              return
            end
          else
            if current_user && authentication.nil?# if user is alrady part of clay
              Rails.logger.info "current user"
              expires_at = auth_hash['credentials']['expires_at'] ? Time.at(auth_hash['credentials']['expires_at']) : Time.now.next_year
               current_user.user_authentications.create!({
                :provider => auth_hash['provider'], 
                :uid => auth_hash['uid'],
                :auth_token => auth_hash['credentials']['token'],
                :expires_at => expires_at,
                :expires => true})
              flash[:notice] = "Authentication successful."
              redirect_to "/settings/account/edit"
              return
            else
              Rails.logger.info "not current user"
            end
          end
          
          #@redirect_url = session[:return_to] || spree.login_url
          #render 'spree/social/social_redirect', :layout => false 
          
          #redirect_back_or_default(root_path)
          flash[:notice] = "Finished Callback"
          redirect_to "/settings/account/edit"
        end
      }
    end
  end

  SpreeSocial::OAUTH_PROVIDERS.each do |provider|
    provides_callback_for provider[1].to_sym
  end

  # When user clicks Cancel, or does not allow stuff
  def failure
    session[:return_to] ||= request.referer
    set_flash_message :alert, :failure, :kind => failed_strategy.name.to_s.humanize, :reason => failure_message
    logger.debug "Strategy: #{failed_strategy.name.to_s.humanize} failed with reason: #{failure_message}"
    #redirect_to spree.login_path
    @redirect_url = session[:return_to] || spree.login_url
    render 'spree/social/social_redirect', :layout => false
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def auth_hash
    request.env["omniauth.auth"]
  end
end
