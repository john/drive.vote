class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    
    if @user.persisted?
      user_type = check_for_user_type(request.env["omniauth.params"])
      session[:user_type] = user_type
   
      if request.env["omniauth.params"].has_key?('campaign')
        slug = request.env["omniauth.params"]['campaign']
        campaign = Campaign.find_by_slug(slug)
        
        if campaign.present?
          supporter = Supporter.create!( user_id: @user.id, campaign_id: campaign.id )
        end
      end
        
      UserMailer.welcome_email(@user).deliver_later
      
      sign_in_and_redirect @user, :event => :authentication, :user_type => user_type #this will throw if @user is not activated
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