class ElectionsController < ApplicationController
  before_action :set_election, only: [:show, :edit, :update, :destroy]

  # GET /elections
  def index
    @elections = Election.all
  end

  # GET /elections/1
  def show
  end

  # # GET /elections/new
  # def new
  #   @election = Election.new
  # end
  #
  # # GET /elections/1/edit
  # def edit
  # end
  #
  # # POST /elections
  # def create
  #   @election = Election.new(election_params)
  #
  #   if @election.save
  #     redirect_to @election, notice: 'Election was successfully created.'
  #   else
  #     render :new
  #   end
  # end
  #
  # # PATCH/PUT /elections/1
  # def update
  #   if @election.update(election_params)
  #     redirect_to @election, notice: 'Election was successfully updated.'
  #   else
  #     render :edit
  #   end
  # end
  #
  # # DELETE /elections/1
  # def destroy
  #   @election.destroy
  #   redirect_to elections_url, notice: 'Election was successfully destroyed.'
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_election
      @election = Election.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def election_params
      params.require(:election).permit(:slug, :name, :description, :date)
    end
end
