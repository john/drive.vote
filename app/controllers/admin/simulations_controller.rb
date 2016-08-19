class Admin::SimulationsController < Admin::AdminApplicationController

  before_action :set_simulation, only: [:stop, :delete]

  def index
    @simulations = Simulation.order('created_at desc').all
    @simulation_defs = Simulation::SIM_DEFS
  end

  def start_new
    if Simulation.can_start_new?
      @simulation = Simulation.create_named_sim(params[:slug])
      @simulation.play
      flash[:notice] = 'Simulation running'
    else
      flash[:notice] = 'Simulation already in progress'
    end
    redirect_to admin_simulations_path
  end

  def stop
    @simulation.stop
    flash[:notice] = 'Simulation being stopped'
    redirect_to admin_simulations_path
  end

  def delete
    @simulation.delete
    redirect_to admin_simulations_path
  end

  private
  def set_simulation
    @simulation = Simulation.find(params[:id])
  end
end
