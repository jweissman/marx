require 'spec_helper'
require 'pry'
require 'marx'

describe Worker do
  describe 'operating machinery' do
    let(:weaver) { Worker.new }

    before do
      weaver.inventory << Wool.units(15)
    end

    it 'consumes inputs' do
      expect { weaver.operate(Loom.new) }.to change { Clothing.quantity(weaver.inventory) }.by(1)
    end

    it 'produces outputs' do
      expect { weaver.operate(Loom.new) }.to change { Wool.quantity(weaver.inventory) }.by(-15)
    end
  end

  describe 'assembling machinery' do
    let(:loom) { Loom.new }
    let(:loom_assembler) { LoomAssembler.new }
    let(:builder) { Worker.new }
    let(:weaver) { Worker.new }
    let(:workshop) { Workshop.new }

    it 'builds a machine which can be operated' do
      workshop.inventory << Steel.units(50)
      # @factory_floor = [ Steel.units(50) ]
      expect { builder.operate(loom_assembler, context: workshop.inventory) }.to change {Loom.quantity(workshop.inventory)}.by(1)
      expect(Steel.quantity(workshop.inventory)).to eq(0)

      weaver.inventory << Wool.units(15)
      expect { weaver.labor!(environment: workshop) }.to change {Clothing.quantity(weaver.inventory)}.by(1)
    end
  end

  describe 'social reproduction' do
    let(:residence) { Residence.new }
    let(:weaver) { Worker.new }
    let(:worker) { Worker.new }

    it 'creates new workers' do
      # redi
    end
  end
end
