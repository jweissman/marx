module Marx
  class Room < Capital
    attr_accessor :inventory
    def initialize(inventory: [])
      @inventory = inventory
      self.class.machines.each do |machine|
        machine.unit.produce!(@inventory)
      end
    end

    def work
      puts "---> Working '#{self.class.sym}' (room)..."
      workers = @inventory.select { |it| it.is_a?(Worker) }
      workers.each do |worker|
        worker.labor!(environment: self)
      end
    end

    class << self
      attr_accessor :activities, :machines, :sym
      def specify(sym, activities: [], machines: [])
        klass = Class.new(Room)
        klass.activities = activities
        klass.machines = machines
        klass.sym = sym
        klass
      end
    end
  end
end
