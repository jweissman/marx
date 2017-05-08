module Marx
  class Machine < Capital
    class << self
      attr_accessor :activities
      def specify(activities:)
        klass = Class.new(Machine)
        klass.activities = activities
        klass
      end
    end

    def perform(context:)
      self.class.activities.detect do |activity|
        activity.operations.each do |operation|
          if operation.input.consume!(context)
            operation.output.produce!(context)
            [operation, activity]
          end
        end
      end
    end
  end
end
