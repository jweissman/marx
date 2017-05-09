module Marx
  class Flow
    attr_accessor :quantity

    def initialize(qty: 0)
      @quantity = qty
    end

    def consume!(stockpile)
      matching_inputs = stockpile.select { |stock| stock.is_a?(self.class) }
      avail_qty = self.class.quantity(stockpile)
      puts "---> Attempting to consume #{name}... Available: #{avail_qty} / Needed: #{@quantity}"
      if avail_qty >= @quantity
        puts "CONSUME #{@quantity} UNIT(S) OF #{name}"
        total_consumed = 0
        matching_inputs.each do |matching_input|
          puts "---> Consider amt to take from #{matching_input}"
          amt_to_take = [ @quantity - total_consumed, matching_input.quantity ].min
          puts "---> Taking #{amt_to_take}"
          matching_input.quantity -= amt_to_take
          total_consumed += amt_to_take
          if total_consumed == @quantity
            # we are done
            puts "---> Finished consuming #{name}..."
            break
          end
        end

        true
      else
        puts "===> Unable to consume required amount (#{@quantity}) of #{name}!"
        false
      end
    end

    def produce!(stockpile)
      puts "PRODUCE #{@quantity} UNIT(S) OF #{name}"
      stockpile << self.class.units(@quantity)
      true
    end

    def name
      self.class.name.split('::').last
    end

    def to_s
      "#{name} x#{quantity}"
    end

    def +(other)
      ConjoinedFlow.new(self, other)
    end

    class << self
      def unit
        units(1)
      end

      def units(n)
        new(qty: n)
      end

      def quantity(stockpile = [])
        matching_inputs = stockpile.select { |stock| stock.is_a?(self) }
        return 0 if matching_inputs.none?
        matching_inputs.map(&:quantity).inject(&:+)
      end
    end
  end

  # a flow of multiple kinds of flows... Steel.units(1) + Plastic.units(1) ...
  class ConjoinedFlow
    def initialize(left, right)
      @left = left
      @right = right
    end

    def consume!(stockpile)
      @left.consume!(stockpile) && @right.consume!(stockpile)
    end

    def produce!(stockpile)
      @left.produce!(stockpile) && @right.produce!(stockpile)
    end
  end
end
