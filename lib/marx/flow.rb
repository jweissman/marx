module Marx
  # base class for everything that's 'reified'...
  class Flow
    class << self
      def unit
        units(1)
      end

      def units(n)
        Stock.new(self, quantity: n)
      end

      def quantity(stockpile)
        matching_inputs = stockpile.select { |it| it.is_a?(self) }
        return 0 if matching_inputs.none?
        matching_inputs.count
      end
    end
  end
end
