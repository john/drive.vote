class Auth0Controller < ApplicationController
  
  
  # BUSTED. Work on it later. 8/1/16 -jm
  
  # def callback
  #   # This stores all the user information that came from Auth0
  #   # and the IdP
  #
  #   logger.debug '------------------------------'
  #   logger.debug "request.env['omniauth.auth']: #{request.env['omniauth.auth'].inspect}"
  #
  #   logger.debug '------------------------------'
  #   logger.debug "request.env['omniauth']: #{request.env['omniauth'].inspect}"
  #
  #   logger.debug '------------------------------'
  #   logger.debug "request.env: #{request.env.inspect}"
  #
  #   logger.debug '------------------------------'
  #
  #   session[:userinfo] = request.env['omniauth.auth']
  #
  #
  #   # @user = User.from_omniauth(request.env["omniauth.auth"], passed_thru_params)
  #
  #
  #   # Redirect to the URL you want after successfull auth
  #   redirect_to root_path
  # end
  #
  # def failure
  #   # show a failure page or redirect to an error page
  #   @error_msg = request.params['message']
  # end
  
end
