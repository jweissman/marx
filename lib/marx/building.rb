module Marx
  class Building < Capital
    attr_reader :rooms

    def initialize
      @rooms = self.class.rooms.map(&:new)
    end

    def work
      puts "---> Work building #{self.class.name}"
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
      attr_accessor :rooms
      def specify(rooms: [])
        klass = Class.new(Building)
        klass.rooms = rooms
        klass
      end
    end
  end
end
