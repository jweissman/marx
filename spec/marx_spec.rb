require 'spec_helper'
require 'pry'
require 'marx'

describe Worker do
  describe 'operating machinery' do
    let(:weaver) { Worker.new }
    let(:workshop) { Workshop.new }

    before do
      workshop.inventory << Wool.units(15)
    end

    it 'consumes inputs' do
      expect { weaver.operate(Loom.new, context: workshop.inventory) }.to change { Clothing.quantity(workshop.inventory) }.by(1)
    end

    it 'produces outputs' do
      expect { weaver.operate(Loom.new, context: workshop.inventory) }.to change { Wool.quantity(workshop.inventory) }.by(-15)
    end
  end

  describe 'assembling machinery' do
    let(:loom) { Loom.new }
    let(:loom_assembler) { LoomAssembler.new }
    let(:builder) { Worker.new }
    let(:weaver) { Worker.new }
    # let(:workshop) { Workshop.new }
    let(:factory) { Factory.new }

    it 'builds a machine which can be operated' do
      factory.workshop.inventory << Steel.units(50)
      # binding.pry

      expect { builder.operate(loom_assembler, context: factory.workshop.inventory) }.to change { Loom.quantity(factory.workshop.inventory) }.by(1)

      expect(Steel.quantity(factory.workshop.inventory)).to eq(0)

      factory.workshop.inventory << Wool.units(15)
      expect { weaver.labor!(environment: factory.workshop) }.to change { Clothing.quantity(factory.workshop.inventory) }.by(1)
    end
  end

  describe 'social reproduction' do
    let(:residence)  { Residence.new }
    let(:parents) { Worker.units(2) }

    it 'creates new workers' do
      bed = Bed.new

      residence.bedroom.inventory << Food.units(10)
      residence.bedroom.inventory << bed
      residence.bedroom.inventory << parents

      expect(Worker.quantity(residence.bedroom.inventory)).to eq(2) #contain_exactly(parent_one, parent_two)

      expect { bed.perform(context: residence.bedroom.inventory) }.to change { Worker.quantity(residence.bedroom.inventory) }.by(1)
    end
  end
end
