require 'rails_helper'

TWO_DRIVERS = <<driver
ride_zone_name: rztest
name: testing
drivers:
  -
    events:
      -
        at: 10
        type: solo
  -
    events:
      -
        at: 30
        type: multi
        repeat_count: 4
        repeat_time: 10
driver

RSpec.describe Simulation, :type => :model do
  let(:sim_name) { Simulation::SIM_DEFS.first.name }
  let(:sim_slug) { Simulation::SIM_DEFS.first.slug }

  describe 'static methods' do
    it 'loads definitions' do
      expect(Simulation::SIM_DEFS.length).to be >(0)
    end

    it 'finds sim by name' do
      expect(Simulation.find_named_sim_def(sim_name)).to_not be_nil
    end

    it 'finds sim by slug' do
      expect(Simulation.find_named_sim_def(sim_slug)).to_not be_nil
    end

    it 'creates a new sim' do
      expect(Simulation.create_named_sim(sim_name)).to_not be_nil
    end
  end

  describe 'drivers and events' do
    let!(:rz) { create :ride_zone, name: 'rztest' }
    let!(:sim_def) { SimDefinition.new.load(TWO_DRIVERS) }
    let(:sim) { Simulation.create_from_def(sim_def) }

    it 'creates drivers' do
      sim.send(:prepare)
      expect(User.count).to eq(2)
    end

    it 'creates events' do
      sim.send(:prepare)
      expect(sim.events.count).to eq(6)
    end
  end

  describe 'missing sim definition' do
    let!(:rz) { create :ride_zone, name: 'rztest' }
    let!(:sim_def) { SimDefinition.new.load(TWO_DRIVERS) }
    let!(:sim) { Simulation.create_from_def(sim_def) }

    it 'handles missing definition' do
      expect(Simulation.first.run_time).to be_nil # because TWO_DRIVERS is not in file system
    end
  end
end
