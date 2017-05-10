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

module Marx
  class Material < Flow; end
  class Wool < Material; end
  class Steel < Material; end
  class Food < Material; end
  class Wood < Material; end

  class Commodity < Flow; end
  class Clothing < Commodity; end
  class Meal < Commodity; end

  class Money < Flow; end
  # class Capital < Flow; end
  # class People < Flow; end

  # hmmm
  class Hunger < Flow; end

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
  Workshop = Room.specify(:workshop, activities: [ Tailoring ], machines: [ Loom ])

  Residence = Building.specify(:residence, rooms: [ Bedroom ])
  Factory   = Building.specify(:factory, rooms: [ Workshop ])

  AridLand     = Land.specify(fertility: 0.2)

  BuildHouse   = Operation.specify(input: Wood.units(150) + Steel.units(100), output: Residence.unit)
  Construction = Activity.specify(operations: [ BuildHouse ])
  Workbench    = Machine.specify(activities: [ Construction ])

  # machines cut flows / transform...
  # workers work machines...
  Clothier = Industry.specify(:clothier, buildings: [ Factory ])

  Megacity = City.specify(industries: [ Clothier ])
end
