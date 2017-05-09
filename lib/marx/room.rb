module Marx
  class Room < Capital
    attr_accessor :inventory
    def initialize(inventory: [])
      @inventory = inventory
    end

    def work
      worker_stock = @inventory.select { |stock| stock.flow_kind == (Worker) }
      workers = Stock.reify(worker_stock)
      puts "---> Reified workers: #{workers}"
      workers.each do |worker|
        worker.labor!(environment: self)
      end
    end

    class << self
      attr_accessor :activities, :sym
      def specify(sym, activities: [])
        klass = Class.new(Room)
        klass.activities = activities
        klass.sym = sym
        klass
      end
    end
  end
end
