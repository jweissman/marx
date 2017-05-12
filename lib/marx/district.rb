module Marx
  # a district is a part of a city... has industries and lands
  class District < Capital
    attr_reader :industries, :lands, :city
    def initialize(city:)
      puts "---> CREATE NEW DISTRICT #{self.class.sym}"
      @city = city

      @lands = self.class.lands.map do |land_class|
        land_class.new(district: self)
      end

      # industries need to go after lands!! since buildings have to be on a land...
      @industries = self.class.industries.map do |industry_class| #(&:new)
        industry_class.new(district: self)
      end
    end

    def work
      @industries.each(&:work)
    end

    def method_missing(meth, *args, &blk)
      if (matching_industry=@industries.detect { |industry| industry.class.sym == meth })
        matching_industry
      else
        super
      end
    end

    class << self
      attr_accessor :sym, :industries, :lands
      def specify(sym, industries:, lands:)
        klass = Class.new(District)
        klass.sym = sym
        klass.industries = industries
        klass.lands = lands
        klass
      end
    end
  end
end
