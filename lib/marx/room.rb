module Marx
  class Room < Capital
    attr_accessor :inventory
    attr_reader :building
    def initialize(building=nil) # inventory: [])
      @building = building
      @inventory = []

      self.class.inventory.map { |it| it.produce!(@inventory) }

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
      (operations.flat_map(&:output) + activities.flat_map(&:output)).uniq.compact
    end

    def consumption
      (operations.flat_map(&:input) + activities.flat_map(&:input)).uniq.compact
    end

    def operations
      activities.flat_map(&:operations).compact
      # self.class.activities.flat_map(&:operations).compact + self.class.machines.flat_map(&:operations).compact
    end

    def activities
      self.class.activities + self.class.machines.flat_map(&:activities)
    end

    def describe
      "--- ROOM #{self.class.sym} ---\n" +
        Flow.analyze(@inventory).map(&:to_s).join("\n -")
    end

    class << self
      attr_accessor :activities, :machines, :inventory, :sym
      def specify(sym, activities: [], machines: [], inventory: [])
        klass = Class.new(Room)
        klass.activities = activities
        klass.machines = machines
        klass.inventory = inventory
        klass.sym = sym
        klass
      end

      def has_matching_ends?(left, right)
        return false if left.class.sym == right.class.sym # don't haul to the same place? this is a weird bug thoug
        # puts "---> Considering whether #{left.class.sym} and #{right.class.sym} have matching ends..."
        stocks_to_consume = Stock.split(right.consumption)
        stocks_to_produce = Stock.split(left.production)
        flows_to_consume = stocks_to_consume.map(&:flow_kind)
        flows_to_produce = stocks_to_produce.map(&:flow_kind)
        # puts "---> Consumption from #{right.class.sym}"
        # puts "---> Production from #{left.class.sym}: #{flows_to_produce} -- does #{right.class.sym} consume?"

        flows_to_consume.any? do |consumed_flow|
          is_produced = flows_to_produce.include?(consumed_flow) #consumed_stock.flow_kind)
          # puts "---> Is #{consumed_flow} produced by #{left.class.sym}? #{is_produced}"
          is_produced
        end
      end

      # TODO def matches? ...
    end
  end
end
