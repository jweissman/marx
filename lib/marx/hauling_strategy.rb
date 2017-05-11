module Marx
  class HaulingStrategy
    attr_accessor :activity, :worker, :context

    def initialize(activity:, worker:, context:)
      @activity = activity
      @worker = worker
      @context = context
    end

    def apply!
      hauling_diagram = city.haul_diagram
      if hauling_diagram.empty?
        puts "(nothing to haul)"
        return
      end
      haul_from_room = hauling_diagram.keys.sample
      haul_to_room = hauling_diagram[haul_from_room].sample
      haul_stock(from: haul_from_room, to: haul_to_room)
    end

    protected
    def city
      @city ||= context.building.industry.district.city
    end

    def haul_stock(from:, to:, qty: 5)
      from_room = city.rooms.shuffle.detect { |room| room.class.sym == from }
      to_room = city.rooms.shuffle.detect { |room| room.class.sym == to }

      Stock.split(from_room.production).each do |produced_flow|
        if Stock.split(to_room.consumption).map(&:flow_kind).include?(produced_flow.flow_kind)
          flow = produced_flow.clone
          flow.quantity = [ flow.quantity, qty ].min
          puts "---> HAUL #{flow} from #{from} to #{to}!!!"
          flow.consume!(from_room.inventory)
          flow.produce!(to_room.inventory)
        end
      end
    end
  end

end
