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
