class Admin::CampaignsController < Admin::AdminApplicationController
  include CampaignParams
  
  before_action :set_campaign, only: [:edit, :update, :destroy]

  def index
    @campaigns = Campaign.all
  end

  def new
    @campaign = Campaign.new
  end

  def edit
  end

  def create
    @campaign = Campaign.new(campaign_params)

    if @campaign.save
      redirect_to admin_campaigns_path, notice: 'Campaign was successfully created.'
    else
      render :new
    end
  end

  def update
    if @campaign.update(campaign_params)
      redirect_to @campaign, notice: 'Campaign was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @campaign.destroy
    redirect_to campaigns_url, notice: 'Campaign was successfully destroyed.'
  end
  
end