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

    it 'builds a machine which can be operated' do
      @factory_floor = [ Steel.units(50) ]
      expect { builder.operate(loom_assembler, context: @factory_floor) }.to change {Loom.quantity(@factory_floor)}.by(1)

      weaver.inventory << Wool.units(15)
      expect { weaver.work!(Loom, environment: @factory_floor) }.to change {Clothing.quantity(weaver.inventory)}.by(1)
    end
  end

  describe 'social reproduction' do
    let(:residence) { Residence.new }
    let(:weaver) { Worker.new }
    let(:worker) { Worker.new }

    # xit 'eats' do
    # end

    it 'creates new workers' do
    end
  end
end
