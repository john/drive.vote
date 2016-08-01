module UserParams
  extend ActiveSupport::Concern

  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    # params.fetch(:user, {})
    params.require(:user).permit(:name, :user_type, :email, :phone_number, :image_url,
    :languages_spoken, :max_passengers, :start_drive_time, :end_drive_time,
    :description, :address1, :address2, :city, :state, :zip, :country, :latitude,
    :longitude, :accepted_tos, :email_list, :agree_to_background_check, :party_affiliation
    )
  end
  
end