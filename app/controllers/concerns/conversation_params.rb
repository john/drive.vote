module ConversationParams
  extend ActiveSupport::Concern

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def conversation_params
    params.require(:conversation).permit(:from_address, :from_city, :to_address, :to_city,
                                         :from_latitude, :from_longitude, :to_latitude, :to_longitude,
                                         :additional_passengers, :special_requests)
  end

  def require_conversation_access
    unless user_signed_in? && has_zone_rights?(@conversation.ride_zone)
      redirect_to '/404.html'
    end
  end

end