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
    alias :inspect :to_s

    def +(other)
      ConjoinedStock.new(self, other)
    end

    def ==(other)
      self.flow_kind == other.flow_kind && self.quantity == other.quantity
    end

    def can_take?(stockpile)
      @flow_kind.quantity(stockpile) >= @quantity
    end

    def consume!(stockpile)
      return unless can_take?(stockpile)
      matching_inputs = stockpile.select { |st| st.is_a?(@flow_kind) }
      puts "CONSUME #{@quantity} UNIT(S) OF #{name}"
      total_consumed = 0
      matching_inputs.each do |matching_input|
        stockpile.delete(matching_input)
        total_consumed += 1
        if total_consumed == @quantity
          break
        end
      end
      true
    end

    def produce!(stockpile)
      puts "PRODUCE #{@quantity} UNIT(S) OF #{name}"
      @quantity.times { stockpile << @flow_kind.new }
      true
    end

    def split!
      self
    end

    class << self
      def split(stock_arr)
        stock_arr.flat_map do |stock|
          if stock.is_a?(ConjoinedStock)
            stock.split!
          else
            stock
          end
        end
      end
    end
  end

  # Wood.unit + Steel.unit ...
  class ConjoinedStock
    attr_reader :left, :right
    def initialize(left, right)
      @left = left
      @right = right
    end

    def can_take?(stockpile)
      @left.can_take?(stockpile) && @right.can_take?(stockpile)
    end

    def consume!(stockpile)
      if can_take?(stockpile) # @left.can_take?(stockpile) && @right.can_take?(stockpile)
        @left.consume!(stockpile)
        @right.consume!(stockpile)
      end
    end

    def produce!(stockpile)
      @left.produce!(stockpile)
      @right.produce!(stockpile)
    end

    def ==(other)
      (@left == other.left && @right == other.right)
    end

    def to_s
      [@left.to_s, @right.to_s].join(';')
    end
    alias :inspect :to_s

    def split!
      [ @left.split!, @right.split! ]
    end
  end
end
