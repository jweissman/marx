module Marx
  # class Human < Flow; end
  class Worker < Flow
    # attr_accessor :inventory
    # def initialize(inventory: [])
    #   # @inventory = inventory
    #   # @environment = nil
    # end

    def labor!(environment:)
      # does environment have a machine? if so operate it!
      # binding.pry
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
