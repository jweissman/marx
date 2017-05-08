module Marx
  class Activity
    class << self
      attr_accessor :operations
      def specify(operations: [])
        klass = Class.new(Activity)
        klass.operations = operations
        klass
      end
    end
  end
end
