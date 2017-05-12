module Marx
  class ConstructingStrategy
    attr_reader :activity, :worker, :context
    def initialize(activity:, worker:, context:)
      @activity = activity
      @worker = worker
      @context = context
    end

    def land
      @land ||= context.building.land #industry.district
    end

    def apply!(building:, input:)
      # create building on district land...
      input.consume!(context.inventory) && \
        building.unit.produce!(land.inventory)
    end
  end
end
