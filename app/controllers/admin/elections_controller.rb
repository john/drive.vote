class Admin::ElectionsController < Admin::AdminApplicationController
  include ElectionParams
  
  before_action :set_election, only: [:edit, :update, :destroy]

  def index
    @elections = Election.all
  end

  def new
    @election = Election.new
  end

  def edit
  end

  def create
    @election = Election.new(election_params)

    if @election.save
      redirect_to admin_elections_path, notice: 'Election was successfully created.'
    else
      render :new
    end
  end

  def update
    if @election.update(election_params)
      redirect_to @election, notice: 'Election was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @election.destroy
    redirect_to elections_url, notice: 'Election was successfully destroyed.'
  end

end