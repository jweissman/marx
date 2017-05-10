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

    def perform(worker:, context:)
      self.class.activities.detect do |activity|
        activity.perform(worker: worker, context: context)
      end
    end
  end
end
