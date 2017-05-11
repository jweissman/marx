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
      operations.flat_map(&:output)
    end

    def consumption
      operations.flat_map(&:input)
    end

    def operations
      self.class.activities.flat_map(&:operations).compact
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

      def has_matching_ends?(left, right)
        return false if left == right # don't haul to the same place? this is a weird bug thoug
        stocks_to_consume = Stock.split(right.consumption)
        stocks_to_produce = Stock.split(left.production)
        flows_to_produce = stocks_to_produce.map(&:flow_kind)

        stocks_to_consume.any? do |consumed_stock|
          flows_to_produce.include?(consumed_stock.flow_kind)
        end
      end

      # TODO def matches? ...
    end
  end
end
