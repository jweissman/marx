module Marx
  class Building < Capital
    attr_reader :rooms, :industry, :land

    def initialize(land: nil, industry: nil)
      @land = land
      @industry = industry
      @rooms = self.class.rooms.map { |room_class| room_class.new(self) } #&:new)
    end

    def work
      puts "---> Working '#{self.class.sym}' (building)..."
      @rooms.each do |room|
        room.work
      end
    end

    def method_missing(meth, *args, &blk)
      if (matching_room=@rooms.detect { |room| room.class.sym == meth })
        matching_room
      else
        super
      end
    end

    class << self
      attr_accessor :rooms, :sym
      def specify(sym, rooms: [])
        klass = Class.new(Building)
        klass.rooms = rooms
        klass.sym = sym
        klass
      end
    end
  end
end
