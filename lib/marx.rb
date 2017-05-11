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
require 'marx/city'
require 'marx/hauling_strategy'

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
  class Hunger < Flow; end

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

  # LightIndustry = Activity.specify(operations: [ Tailoring ])

  Bedroom  = Room.specify(:bedroom, activities: [ Reproduction ], machines: [ Bed ])
  Workshop = Room.specify(:workshop, activities: [ Tailoring ], machines: [ Loom ]) #, requests: [ Wool ])

  Residence = Building.specify(:residence, rooms: [ Bedroom ])
  Factory   = Building.specify(:factory, rooms: [ Workshop ])

  # LlamaQuarters = Room.specify(:workshop
  class Animal < Flow; end
  class Llama < Animal; end

  ShearWool = Operation.specify(input: Llama.unit, output: Llama.unit + Wool.units(50))
  ShearingWool = Activity.specify(operations: [ ShearWool ])
  # Llama = Machine.specify(activities: [ ShearingWool ])
  AnimalQuarters = Room.specify(:animal_quarters, activities: [ ShearingWool ], machines: [ Llama ]) # not a machine!
  Barn           = Building.specify(:barn, rooms: [ AnimalQuarters ])

  AridLand     = Land.specify(fertility: 0.2)

  BuildHouse   = Operation.specify(input: Wood.units(150) + Steel.units(100), output: Residence.unit)
  Constructing = Activity.specify(operations: [ BuildHouse ])
  Workbench    = Machine.specify(activities: [ Constructing ])
  ConstructionYard = Room.specify(:construction_yard, activities: [ Constructing ], machines: [ Workbench ])
  BuildersHall = Building.specify(:builder_hall, rooms: [ ConstructionYard ])
  # = Room.

  Storeroom = Room.specify(:storeroom, activities: [ Haul ])
  Warehouse = Building.specify(:warehouse, rooms: [Storeroom])

  # machines cut flows / transform...
  # workers work machines...
  Clothier = Industry.specify(:clothier, buildings: [ Factory ])
  Agriculture = Industry.specify(:agriculture, buildings: [ Barn ])
  Transport = Industry.specify(:transport, buildings: [ Warehouse ])
  Construction = Industry.specify(:construction, buildings: [ BuildersHall ])

  # city *districts* could manage land... (and maybe specify 'local' industries...? some feel like they 'need' to be global... construction/transport!)
  Megacity = City.specify(industries: [ Clothier, Agriculture, Transport, Construction ]) # Sanitation? Utilities? Land mgmt?
end
