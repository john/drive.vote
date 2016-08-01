module ElectionParams
  extend ActiveSupport::Concern

  private
  
  def set_election
    @election = Election.find(params[:id])
  end
  
  # Never trust parameters from the scary internet, only allow the white list through.
  def election_params
    params.require(:election).permit(:owner_id, :slug, :name, :description, :date)
  end

end