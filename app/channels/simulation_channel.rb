class SimulationChannel < ApplicationCable::Channel
  # called when a new admin simulation connection is established
  def subscribed
    logger.debug "Simulation connection from #{current_user.name}"

    # Set up a stream for simulations
    stream_from 'simulation'
  end
end
