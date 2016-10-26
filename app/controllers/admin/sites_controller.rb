class Admin::SitesController < Admin::AdminApplicationController
  def show
    @site = Site.instance
  end

  def edit
    @site = Site.instance
  end

  def update
    respond_to do |format|
      site_params = params.require(:site).permit(:update_location_interval, :waiting_rides_interval)
      @site = Site.instance
      if @site.update(site_params)
        format.html do
          redirect_to admin_site_path, notice: 'Site configuration was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @site }
      else
        format.html { render :edit }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end
end
