require 'marx/version'
require 'marx/flow'
require 'marx/operation'
require 'marx/activity'
require 'marx/capital'
require 'marx/machine'
require 'marx/worker'

module Marx
  class Material < Flow; end
  class Wool < Material; end
  class Steel < Material; end
  class Food < Material; end

  class Commodity < Flow; end
  class Clothing < Commodity; end
  class Meal < Commodity; end

  class Money < Flow; end
  # class Capital < Flow; end
  # class People < Flow; end

  # hmmm
  class Hunger < Flow; end

  Reproduce = Operation.specify(input: Human.units(2), output: Human.units(3))
  Reproduction = Activity.specify(operations: [ Reproduce ])
  Bed = Machine.specify(activities: [ Reproduction ])

  # PrepareMeal = Operation.specify(input: Food.units(20), output: Meal.unit)
  # EatFood = Operation.specify(input: Meal.unit, output: Hunger.units(-1))
  # Eating = Activity.specify(operations: [ EatFood ])
  # DiningTable = Machine.specify(activities: [ Eating ])

  MakeClothes = Operation.specify(input: Wool.units(15), output: Clothing.unit)
  Tailoring = Activity.specify(operations: [ MakeClothes ])
  Loom = Machine.specify(activities: [ Tailoring ])

  ConstructLoom = Operation.specify(input: Steel.units(50), output: Loom.unit)
  Loommaking = Activity.specify(operations: [ ConstructLoom ])
  LoomAssembler = Machine.specify(activities: [ Loommaking ])

  LightIndustry = Activity.specify(operations: [ Tailoring ])

  class Room < Capital
    attr_accessor :inventory
    def initialize(inventory: [])
      @inventory = inventory
    end

    class << self
      attr_accessor :activities #, :stoc
      def specify(activities: [])
        klass = Class.new(Room)
        klass.activities = activities
        klass
      end
    end
  end

  Bedroom = Room.specify(activities: [ Reproduction ])
  # DiningHall = Room.specify(activities: [ Eating ])
  Workshop = Room.specify(activities: [ LightIndustry ])

  class Building < Capital
    class << self
      attr_accessor :rooms
      def specify(rooms: [])
        klass = Class.new(Building)
        klass.rooms = rooms
        klass
      end
    end
  end

  Residence = Building.specify(rooms: [ Bedroom ])
  Factory = Building.specify(rooms: [ Workshop ])

  # machines cut flows / transform...
  # workers work machines...

  # an industry may be an 'assemblage' of machines with workers/buildings/etc... ?
  # class Industry < Capital
  # end
end
