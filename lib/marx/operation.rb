module Marx
  class Operation
    class << self
      attr_accessor :input, :output
      def specify(input:, output:)
        klass = Class.new(Operation)
        klass.input = input
        klass.output = output
        klass
      end
    end
  end
end
