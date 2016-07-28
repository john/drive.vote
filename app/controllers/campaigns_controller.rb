class CampaignsController < ApplicationController
  include CampaignParams
  
  before_action :set_campaign, only: [:show]

  # GET /campaigns
  def index
    @campaigns = Campaign.all
  end

  # GET /campaigns/1
  def show
  end

end
