require 'marx/version'
require 'marx/stock'
require 'marx/flow'
require 'marx/operation'
require 'marx/activity'
require 'marx/capital'
require 'marx/machine'
require 'marx/worker'
require 'marx/room'
require 'marx/building'
require 'marx/industry'
require 'marx/land'
require 'marx/district'
require 'marx/city'
require 'marx/hauling_strategy'
require 'marx/constructing_strategy'

module Marx
  class Material < Flow; end
  class Wool < Material; end
  class Steel < Material; end
  class Food < Material; end
  class Wood < Material; end

  class Commodity < Flow; end
  class Clothing < Commodity; end
  # class Meal < Commodity; end

  # class Money < Flow; end
  # class Capital < Flow; end
  # class People < Flow; end

  # hmmm
  # class Hunger < Flow; end

  Haul = Activity.specify do |activity:, worker:, context:|
    strategy = HaulingStrategy.new(activity: activity, worker: worker, context: context)
    strategy.apply!
  end

  Reproduce    = Operation.specify(input: Worker.units(2) + Food.units(10), output: Worker.units(3))
  Reproduction = Activity.specify(operations: [ Reproduce ])
  Bed          = Machine.specify(activities: [ Reproduction ])

  # PrepareMeal = Operation.specify(input: Food.units(20), output: Meal.unit)
  # EatFood = Operation.specify(input: Meal.unit, output: Hunger.units(-1))
  # Eating = Activity.specify(operations: [ EatFood ])
  # DiningTable = Machine.specify(activities: [ Eating ])

  MakeClothes = Operation.specify(input: Wool.units(15), output: Clothing.unit)
  Tailoring   = Activity.specify(operations: [ MakeClothes ])
  Loom        = Machine.specify(activities: [ Tailoring ])

  ConstructLoom = Operation.specify(input: Steel.units(50), output: Loom.unit)
  Loommaking    = Activity.specify(operations: [ ConstructLoom ])
  LoomAssembler = Machine.specify(activities: [ Loommaking ])

  Bedroom  = Room.specify(:bedroom, activities: [ Reproduction ], machines: [ Bed ])
  Workshop = Room.specify(:workshop, activities: [ Tailoring ], machines: [ Loom ]) #, requests: [ Wool ])

  Residence = Building.specify(:residence, rooms: [ Bedroom ])
  Factory   = Building.specify(:factory, rooms: [ Workshop ])

  class Animal < Flow; end
  class Llama < Animal; end

  ShearWool = Operation.specify(input: Llama.unit, output: Llama.unit + Wool.units(50))
  ShearingWool = Activity.specify(operations: [ ShearWool ])
  AnimalQuarters = Room.specify(:animal_quarters, activities: [ ShearingWool ], inventory: [ Llama.unit ]) # not a machine!
  Barn           = Building.specify(:barn, rooms: [ AnimalQuarters ])

  AridLand     = Land.specify(fertility: 0.2)
  Woodland     = Land.specify(fertility: 0.5)
  # Farmland     = Land.specify(fertility: 0.7)

  # BuildHouse   = Operation.specify(input: Wood.units(150) + Steel.units(100), output: Residence.unit)
  # Constructing = Activity.specify do #(operations: [ BuildHouse ])
  # end

  # TODO not able to reflect inputs anymore :(
  Construct = ->(building:, input:) do
    Activity.specify(input: input, output: building.unit) do |activity:, worker:, context:|
      strategy = ConstructingStrategy.new(activity: activity, worker: worker, context: context)
      strategy.apply!(building: building, input: input)
    end
  end

  BuildHouse = Construct[building: Residence, input: Wood.units(150) + Steel.units(100)]

  Workbench    = Machine.specify(activities: [ BuildHouse ])
  ConstructionYard = Room.specify(:construction_yard, machines: [ Workbench ])
  BuildersHall = Building.specify(:builder_hall, rooms: [ ConstructionYard ])
  # = Room.

  Storeroom = Room.specify(:storeroom, activities: [ Haul ])
  Warehouse = Building.specify(:warehouse, rooms: [ Storeroom ])

  class Tool < Flow; end
  class Pick < Tool; end

  class Ore < Material; end

  MineOre   = Operation.specify(input: Ore.unit, output: Steel.units(100))
  OreMining = Activity.specify(operations: [ MineOre ])
  Tunnel    = Room.specify(:tunnel, activities: [ OreMining ], inventory: [ Pick.unit, Ore.units(1_000) ])
  Mine      = Building.specify(:mine, rooms: [ Tunnel ])

  class Tree < Material; end
  # class Woodmaker < Machine; end
  ProduceWood    = Operation.specify(input: Tree.unit, output: Wood.units(75))
  WoodProcessing = Activity.specify(operations: [ ProduceWood ])
  Shredder       = Room.specify(:shredder, activities: [ WoodProcessing ], inventory: [ Tree.units(100) ])
  Lumberyard     = Building.specify(:lumberyard, rooms: [ Shredder ])

  # machines cut flows / transform...
  # workers work machines...
  Clothier     = Industry.specify(:clothier, buildings: [ Factory ])
  Agriculture  = Industry.specify(:agriculture, buildings: [ Barn ])
  Transport    = Industry.specify(:transport, buildings: [ Warehouse ])
  Construction = Industry.specify(:construction, buildings: [ BuildersHall ])
  Forestry     = Industry.specify(:forestry, buildings: [ Lumberyard ])
  Mining       = Industry.specify(:mining, buildings: [ Mine ])
  # Sociality

  Natural     = District.specify(:natural, industries: [ Forestry, Mining ], lands: [ Woodland ])
  Industrial  = District.specify(:industrial, industries: [ Transport, Agriculture ], lands: [ AridLand ])
  Residential = District.specify(:residential, industries: [ Construction ], lands: [ AridLand ])
  Commercial  = District.specify(:commercial, industries: [ Clothier ], lands: [ AridLand ])
  # Entertainment
  # Food ...

  # city *districts* could manage land... (and maybe specify 'local' industries...? some feel like they 'need' to be global... construction/transport!)
  Megacity = City.specify(districts: [ Industrial, Commercial, Residential, Natural ])
    #industries: [ Clothier, Agriculture, Transport, Construction ]) # Sanitation? Utilities? Land mgmt?
end
