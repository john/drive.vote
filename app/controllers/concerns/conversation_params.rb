module ConversationParams
  extend ActiveSupport::Concern

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def conversation_params
    params.require(:conversation).permit(:from_address, :from_city, :to_address, :to_city,
                                         :from_latitude, :from_longitude, :to_latitude, :to_longitude,
                                         :additional_passengers, :special_requests)
  end

end