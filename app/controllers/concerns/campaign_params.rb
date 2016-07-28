module CampaignParams
  extend ActiveSupport::Concern

  private
  
  def set_campaign
    @campaign = Campaign.find(params[:id])
  end
  
  # Never trust parameters from the scary internet, only allow the white list through.
  def campaign_params
    params.require(:campaign).permit(:election_id, :slug, :name, :party_affiliation, :description, :start_date)
  end

end