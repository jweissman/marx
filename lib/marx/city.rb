module Marx
  # cities have industry kinds (will need lands??)...
  class City < Capital
    def initialize
      @districts = self.class.districts.map do |district_class|
        district_class.new(city: self)
      end
      # @industries = self.class.industries.map do |industry_class| #(&:new)
      #   industry_class.new(self)
      # end
      # super
    end

    def work
      @districts.each(&:work)
    end

    def industries
      @districts.flat_map(&:industries)
    end

    def rooms
      industries.flat_map(&:buildings).flat_map(&:rooms)
    end

    def haul_diagram
      # puts "---> Assembling haul diagram..."
      # map -- place to haul from => places to haul to.
      rooms.inject({}) do |hash, haul_from_room|
        # puts "---> Consider where to haul goods from #{haul_from_room.class.sym}..."
        if Stock.split(haul_from_room.production).any?
          # puts "---> #{haul_from_room.class.sym} has production: #{haul_from_room.production}"
          haul_to_rooms = rooms.select do |haul_to_room|
            # puts "---> Checking whether #{haul_to_room.class.sym} has matching consumption..."
            Room.has_matching_ends?(haul_from_room, haul_to_room)
          end

          if haul_to_rooms.any?
            # puts "---> Found rooms with matching consumption: #{haul_to_rooms.map(&:class).map(&:sym)}"
            hash[haul_from_room.class.sym] = haul_to_rooms.map(&:class).map(&:sym)
          end
        end
        hash
      end
    end

    # def production_matches_consumption?(left, right)
    #   return false if left == right
    #   Stock.split(right.consumption).any? do |consumed_stock|
    #     Stock.split(left.production).map(&:flow_kind).include?(consumed_stock.flow_kind)
    #   end
    # end

    def method_missing(meth, *args, &blk)
      if (matching_district=@districts.detect { |district| district.class.sym == meth })
        matching_district
      elsif (matching_industry=industries.detect { |industry| industry.class.sym == meth })
        matching_industry
      else
        super
      end
    end

    def describe
      "===== CITY =====\n" + \
        @districts.map(&:describe).join("\n")
    end

    # def work
    #   @industries.each(&:work)
    # end

    class << self
      attr_accessor :districts
      def specify(districts:)
        klass = Class.new(City)
        klass.districts = districts
        klass
      end
    end
  end
end
