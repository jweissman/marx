module Marx
  # a stock *indicates* an amount to flow..
  class Stock
    attr_reader :flow_kind
    attr_accessor :quantity

    def initialize(flow_kind, quantity: 1)
      @flow_kind = flow_kind
      @quantity = quantity
    end

    def name
      @flow_kind.name.split('::').last
    end

    def to_s
      "#{@flow_kind.name} x#{quantity}"
    end

    def +(other)
      ConjoinedStock.new(self, other)
    end

    def can_take?(stockpile)
      @flow_kind.quantity(stockpile) >= @quantity
    end

    def consume!(stockpile)
      return unless can_take?(stockpile)
      # binding.pry
      matching_inputs = stockpile.select { |st| st.is_a?(@flow_kind) } #flow_kind == @flow_kind }
      avail_qty = @flow_kind.quantity(stockpile)
      puts "---> Attempting to consume #{name}... Available: #{avail_qty} / Needed: #{@quantity}"
      if avail_qty >= @quantity
        puts "CONSUME #{@quantity} UNIT(S) OF #{name}"
        total_consumed = 0
        matching_inputs.each do |matching_input|
          # puts "---> Consider amt to take from #{matching_input}"
          # amt_to_take = 1 #[ @quantity - total_consumed, matching_input.quantity ].min
          # puts "---> Taking #{amt_to_take}"
          # matching_input.quantity -= amt_to_take
          stockpile.delete(matching_input)
          total_consumed += 1 # amt_to_take
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
      @quantity.times { stockpile << @flow_kind.new }
      true
    end
  end

  class ConjoinedStock
    def initialize(left, right)
      @left = left
      @right = right
    end

    def consume!(stockpile)
      if @left.can_take?(stockpile) && @right.can_take?(stockpile)
        @left.consume!(stockpile)
        @right.consume!(stockpile)
      end
    end
  end

  # base class for everything that's 'reified'...
  class Flow
    class << self
      def unit
        units(1)
      end

      def units(n)
        Stock.new(self, quantity: n)
      end

      def quantity(stockpile) # = [])
        matching_inputs = stockpile.select { |it| it.is_a?(self) } #flow_kind == self }
        return 0 if matching_inputs.none?
        matching_inputs.count #map(&:quantity).inject(&:+)
      end
    end
  end

  # a flow of multiple kinds of flows... Steel.units(1) + Plastic.units(1) ...
  # class ConjoinedFlow
  #   def initialize(left, right)
  #     @left = left
  #     @right = right
  #   end

  #   def consume!(stockpile)
  #     @left.consume!(stockpile) && @right.consume!(stockpile)
  #   end

  #   def produce!(stockpile)
  #     @left.produce!(stockpile) && @right.produce!(stockpile)
  #   end
  # end
end
