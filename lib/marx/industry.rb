module Marx
  # an industry is an 'assemblage' of machines with workers/buildings/land/etc
  class Industry < Capital
    attr_reader :district, :buildings
    def initialize(district: nil, worker_count: 1)
      @district = district
      @buildings = self.class.buildings.map do |building_class| #&:new)
        if @district && @district.lands.any?
          building_class.new(industry: self, land: @district.lands.sample)
        else
          building_class.new(industry: self)
        end
      end
      rooms = @buildings.flat_map(&:rooms)
      worker_count.times { place_worker(rooms.sample) }
    end

    def add_building(building_class)
      land = @district.lands.sample
      building = building_class.new(industry: self, land: land)
      @buildings << building
      building
    end

    def place_worker(room)
      puts "---> Place worker in room #{room}"
      Worker.unit.produce!(room.inventory)
    end

    def work
      puts "---> Working '#{self.class.sym}' (industry)..."
      @buildings.each(&:work)
    end

    def method_missing(meth, *args, &blk)
      if (matching_bldg=@buildings.detect { |building| building.class.sym == meth })
        matching_bldg
      else
        super
      end
    end

    def describe
      "--- INDUSTRY #{self.class.sym} ---\n" +
        @buildings.map(&:describe).join("\n")
    end

    class << self
      attr_accessor :buildings, :sym
      def specify(sym, buildings:)
        klass = Class.new(Industry)
        klass.buildings = buildings
        klass.sym = sym
        klass
      end
    end
  end
end
