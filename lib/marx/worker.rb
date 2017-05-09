module Marx
  class Human < Flow; end
  class Worker < Flow
    attr_accessor :inventory

    def initialize(inventory: [])
      @inventory = inventory
    end

    def labor!(environment:)
      # does environment have a machine? if so operate it!
      environment.inventory.detect do |machine|
        if machine.respond_to?(:perform)
          operate machine
        end
      end
    end

    def operate(machine, context: @inventory)
      machine.perform(context: context)
    end
  end
end
