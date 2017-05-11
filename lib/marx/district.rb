module Marx
  # a district is a part of a city... has industries and lands???
  class District < Capital
    attr_reader :industries, :city
    def initialize(city)
      @city = city
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
      attr_accessor :sym, :industries
      def specify(sym, industries:) #, lands:)
        klass = Class.new(District)
        klass.sym = sym
        klass.industries = industries
        klass
      end
    end
  end
end
