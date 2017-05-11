module Marx
  class Room < Capital
    attr_accessor :inventory
    attr_reader :building
    def initialize(building=nil, inventory: [])
      @building = building
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

    def production
      # machines = @inventory.select { |it| it.is_a?(Machine) }
      operations.flat_map(&:output)
        # .flat_map(&:operations).flat_map(&:output) +
    end

    def consumption
      operations.flat_map(&:input)
      # machines.flat_map(&:operations).flat_map(&:input)
    end

    def operations
      self.class.activities.flat_map(&:operations).compact
      # + self.class.machines.flat_map do |machine_class|
      #   if machine_class.respond_to?(:activities)
      #     machine_class.activities.flat_map(&:operations)
      #   else
      #     []
      #   end
      # end
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
