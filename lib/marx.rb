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

  Haul = Activity.specify do |activity:, worker:, context:|
    puts "=========> Worker #{worker} would haul! Context: #{context} <============"
    city = context.building.industry.city
    puts "---> city: #{city}"

    haul_to_candidates = city.rooms.select do |room|
      # binding.pry
      room.consumption.any?
    end
    puts "---> Haul-to candidates: #{haul_to_candidates}"

    haul_from_candidate = city.rooms.detect do |room|
      # TODO ....
      # binding.pry
      room.production.any? && room.production.all? do |produced_stock|
        produced_stock.quantity > 0 && (haul_to_candidates - [room]).any? do |haul_to_candidate|
          # check that there's at least one candidate room actually looking for these things...
          # binding.pry
          haul_to_candidate.consumption.all? { |it| room.production.include?(it) }
        end
      end
    end
    puts "---> Haul-from candidate: #{haul_from_candidate}"
    # puts "---> rooms: #{city.rooms}"
    # okay, we know the rooms -- and what each room consumes/produces
    # binding.pry
    # we need to haul produced flows that are required by some consumd flow...
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
  Construction = Activity.specify(operations: [ BuildHouse ])
  Workbench    = Machine.specify(activities: [ Construction ])

  Storeroom = Room.specify(:storeroom, activities: [ Haul ])
  Warehouse = Building.specify(:warehouse, rooms: [Storeroom])

  # machines cut flows / transform...
  # workers work machines...
  Clothier = Industry.specify(:clothier, buildings: [ Factory ])
  Agriculture = Industry.specify(:agriculture, buildings: [ Barn ])
  Transport = Industry.specify(:transport, buildings: [ Warehouse ])

  # city *districts* could specify industries...
  Megacity = City.specify(industries: [ Clothier, Agriculture, Transport ])
end
