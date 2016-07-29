class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    
    passed_thru_params = request.env["omniauth.params"]
    @user = User.from_omniauth(request.env["omniauth.auth"], passed_thru_params)
    
    if @user.persisted?
      user_type = check_for_user_type(passed_thru_params)
      
      if user_type.present?
        @user.user_type = user_type
        @user.save
      end
      
      session[:user_type] = user_type
      
   
      # if params.has_key?('locale')
      if passed_thru_params.has_key?('campaign')
        
        slug = passed_thru_params['campaign']
        campaign = Campaign.find_by_slug(slug)
        
        if campaign.present?
          supporter = Supporter.create!( user_id: @user.id, campaign_id: campaign.id, locale: passed_thru_params['locale'])
        end
      end
      
      #if Rails.env.production?
        # http://azukiweb.com/blog/2015/activejob-on-heroku-rails-4/
        # UserMailer.welcome_email(@user).deliver_later
        UserMailer.welcome_email(@user).deliver_now
      #end
      
      sign_in_and_redirect @user, event: :authentication, user_type: user_type, is_new_user: true #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      # redirect_to new_user_registration_url
      redirect_to root_path, notice: "Something went wrong."
    end
  end

  def failure
    redirect_to root_path
  end
  
end