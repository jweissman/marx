require 'marx/version'
require 'marx/flow'
require 'marx/operation'
require 'marx/activity'
require 'marx/capital'
require 'marx/machine'

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
  class People < Flow; end

  # hmmm
  class Hunger < Flow; end

  PrepareMeal = Operation.specify(input: Food.units(20), output: Meal.unit)
  EatFood = Operation.specify(input: Meal.unit, output: Hunger.units(-1))
  Eating = Activity.specify(operations: [ EatFood ])

  MakeClothes = Operation.specify(input: Wool.units(15), output: Clothing.unit)
  Tailoring = Activity.specify(operations: [ MakeClothes ])
  Loom = Machine.specify(activities: [ Tailoring ])

  ConstructLoom = Operation.specify(input: Steel.units(50), output: Loom.unit)
  Loommaking = Activity.specify(operations: [ ConstructLoom ])
  LoomAssembler = Machine.specify(activities: [ Loommaking ])


  class Room < Capital
    class << self
      attr_accessor :activities
      def specify(activities: [])
        klass = Class.new(Room)
        klass.activities = activities
        klass
      end
    end
  end

  DiningHall = Room.specify(activities: [ Eating ])

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

  Residence = Building.specify(rooms: [ DiningHall ])

  # cut flows / transform...

  # work machines...
  class Worker < People
    attr_accessor :inventory

    def initialize(inventory: [])
      @inventory = inventory
    end

    def work!(machine_kind, environment:)
      # does environment have a machine kind? if so operate it!
      matching_machine = environment.detect do |stock|
        stock.is_a?(machine_kind)
      end

      if matching_machine
        operate(matching_machine)
        true
      else
        puts "---> No maching of kind #{machine_kind} to operate!"
        false
      end
    end

    def operate(machine, context: @inventory)
      machine.perform(context: context)
      # if machine.class.input.consume!(context)
      #   machine.class.output.produce!(context)
      # end
    end
  end

  # an industry is an 'assemblage' of machines with workers...
  class Industry < Capital
  end
end
