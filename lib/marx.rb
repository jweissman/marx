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

  class HaulingStrategy
    attr_accessor :activity, :worker, :context

    def initialize(activity:, worker:, context:)
      @activity = activity
      @worker = worker
      @context = context
    end

    def apply!
      hauling_diagram = city.haul_diagram
      haul_from_room = hauling_diagram.keys.sample
      haul_to_room = hauling_diagram[haul_from_room].sample
      haul_stock(from: haul_from_room, to: haul_to_room)
    end

    protected
    def city
      @city ||= context.building.industry.city
    end

    def haul_stock(from:, to:)
      from_room = city.rooms.shuffle.detect { |room| room.class.sym == from }
      to_room = city.rooms.shuffle.detect { |room| room.class.sym == to }

      Stock.split(from_room.production).each do |produced_flow|
        if Stock.split(to_room.consumption).map(&:flow_kind).include?(produced_flow.flow_kind)
          puts "---> HAUL #{produced_flow} from #{from} to #{to}!!!"
          flow = produced_flow.clone
          flow.quantity = [ flow.quantity, 5 ].min
          flow.consume!(from_room.inventory)
          flow.produce!(to_room.inventory)
        end
      end
    end
  end

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
  Megacity = City.specify(industries: [ Clothier, Agriculture, Transport ]) # Sanitation? Utilities? Land mgmt?
end
