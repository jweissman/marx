module Marx
  class Worker < Flow
    # attr_accessor :inventory
    # def initialize(inventory: [])
    #   @inventory = inventory
    # end

    def labor!(environment:)
      # does environment have a machine in stock? if so operate it!
      environment.inventory.detect do |machine|
        if machine.respond_to?(:perform)
          operate machine, context: environment.inventory
        end
      end
    end

    def operate(machine, context:)
      machine.perform(context: context)
    end
  end
end
