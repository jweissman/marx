module Marx
  class Land < Capital
    attr_accessor :inventory
    def initialize(inventory: [])
      @inventory = inventory
    end

    class << self
      attr_accessor :fertility
      def specify(fertility:)
        klass = Class.new(Land)
        klass.fertility = fertility
        klass
      end
    end
  end
end
