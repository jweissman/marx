require 'spec_helper'
require 'pry'
require 'marx'

# example materials for flow spec
class Energy < Material; end
class Light < Energy; end
class Matter < Material; end

describe Flow do
  it 'can be cut' do
    # indicating units of flow gives a 'stock'
    expect(Energy.unit).to be_a(Stock)
    expect(Energy.units(2)).to be_a(Stock)

    # stocks may be added together
    expect(Energy.unit + Matter.unit).to be_a(ConjoinedStock)

    # flows can produce 'reified' entities
    room = Bedroom.new
    Light.unit.produce!(room.inventory)
    expect(room.inventory.last).to be_a(Light)

    # flow meter: use Flow.quantity to count entities in an inventory...
    expect(Light.quantity(room.inventory)).to eq(1)
  end
end

describe Worker do
  describe 'operating machinery' do
    let(:weaver) { Worker.new }
    let(:workshop) { Workshop.new }

    before do
      Wool.units(15).produce!(workshop.inventory)
      # workshop.inventory << Wool.units(15)
    end

    it 'consumes inputs' do
      # binding.pry
      expect { weaver.operate(Loom.new, context: workshop) }.to change { Clothing.quantity(workshop.inventory) }.by(1)
    end

    it 'produces outputs' do
      # binding.pry
      expect { weaver.operate(Loom.new, context: workshop) }.to change { Wool.quantity(workshop.inventory) }.by(-15)
    end
  end

  describe 'assembling machinery' do
    let(:loom) { Loom.new }
    let(:loom_assembler) { LoomAssembler.new }
    let(:builder) { Worker.new }
    let(:weaver) { Worker.new }
    let(:factory) { Factory.new }

    it 'builds a machine which can be operated' do
      Steel.units(50).produce!(factory.workshop.inventory)

      expect { builder.operate(loom_assembler, context: factory.workshop) }.to change { Loom.quantity(factory.workshop.inventory) }.by(1)

      expect(Steel.quantity(factory.workshop.inventory)).to eq(0)

      Wool.units(15).produce!(factory.workshop.inventory)
      expect { weaver.labor!(environment: factory.workshop) }.to change { Clothing.quantity(factory.workshop.inventory) }.by(1)
    end
  end

  describe 'buildings' do
    let(:builder) { Worker.new }
    let(:district) { Residential.new }
    let(:industry) { district.construction }
    let(:desert) { district.lands.first }
    it 'can make a building' do
      hall = industry.add_building(BuildersHall)
      # hall = BuildersHall.new(land: desert, industry: industry)
      yard = hall.construction_yard
      Wood.units(150).produce!(yard.inventory)
      Steel.units(100).produce!(yard.inventory)
      # Workbench.unit.produce!(desert.inventory)
      expect { builder.labor!(environment: yard) }.to change { Residence.quantity(desert.inventory) }.by(1)
    end
  end

  describe 'social reproduction' do
    let(:residence)  { Residence.new }

    it 'creates new workers' do
      Food.units(10).produce!(residence.bedroom.inventory)
      # Bed.unit.produce!(residence.bedroom.inventory)

      # two to tango!
      Worker.units(2).produce!(residence.bedroom.inventory)

      expect { residence.work }.to change { Worker.quantity(residence.bedroom.inventory) }.by(1)
      expect(Food.quantity(residence.bedroom.inventory)).to eq(0)
    end
  end
end

describe Room do
  subject(:bedroom) { Bedroom.new }
  it 'indicates what is required (consumed) and what is produced by machines/activities' do
    # binding.pry
    expect(subject.consumption).to eq([Worker.units(2) + Food.units(10)])
    expect(subject.production).to eq([Worker.units(3)])
  end
end

describe Industry do
  subject(:clothier) { Clothier.new }
  it 'should move workers around and make them work' do
    Wool.units(15).produce!(clothier.factory.workshop.inventory)

    expect { clothier.work }.to change { Clothing.quantity(clothier.factory.workshop.inventory) }.by(1)
  end
end

describe City do
  subject(:megacity) { Megacity.new }
  it 'should operate industries' do
    Wool.units(15).produce!(megacity.clothier.factory.workshop.inventory)

    expect { megacity.work }.to change { Clothing.quantity(megacity.clothier.factory.workshop.inventory) }.by(1)
  end
end
