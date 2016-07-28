class ElectionsController < ApplicationController
  include ElectionParams
  
  before_action :set_election, only: [:show, :edit, :update, :destroy]

  # GET /elections
  def index
    @elections = Election.all
  end

  # GET /elections/1
  def show
  end

end
