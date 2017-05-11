module Marx
  # cities have industry kinds (will need lands??)...
  class City < Capital
    def initialize
      @industries = self.class.industries.map do |industry_class| #(&:new)
        industry_class.new(self)
      end
      # super
    end

    def rooms
      @industries.flat_map(&:buildings).flat_map(&:rooms)
    end

    def haul_diagram
      # map -- place to haul from => places to haul to
      rooms.inject({}) do |hash, haul_from_room|
        if haul_from_room.production.any?
          haul_to_rooms = rooms.select do |haul_to_room|
            production_matches_consumption?(haul_from_room, haul_to_room)
          end
          if haul_to_rooms.any?
            hash[haul_from_room.class.sym] = haul_to_rooms.map(&:class).map(&:sym)
            hash
          else
            hash
          end
        else
          hash
        end
      end
    end

    def production_matches_consumption?(left, right)
      return false if left == right
      Stock.split(right.consumption).any? do |consumed_stock|
        Stock.split(left.production).map(&:flow_kind).include?(consumed_stock.flow_kind)
      end # or is a subset...?
    end

    def method_missing(meth, *args, &blk)
      if (matching_room=@industries.detect { |industry| industry.class.sym == meth })
        matching_room
      else
        super
      end
    end

    def work
      @industries.each(&:work)
    end

    class << self
      attr_accessor :industries
      def specify(industries:)
        klass = Class.new(City)
        klass.industries = industries
        klass
      end
    end
  end
end
