class HomeController < ApplicationController

  def index
    @is_new_user = params['is_new_user'].present?
  end

  def confirm
    @contact_email = "hello@drive.vote"

    if params[:uid].present?
      user = User.find(params[:uid])
      if user.is_voter?
        @contact_email = rz.email if rz = RideZone.find(user.voter_ride_zone_id)
      elsif user.is_unassigned_driver? || user.is_driver?
        @contact_email = rz.email if rz = RideZone.find(user.driver_ride_zone_id)
      end
    end
  end

  def about
  end

  def code_of_conduct
  end

  def terms_of_service
  end

  def privacy
  end

end
