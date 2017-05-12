module Marx
  class Activity
    class << self
      attr_accessor :operations, :procedure, :input, :output
      def specify(operations: [], input: [], output: [], &blk)
        klass = Class.new(Activity)
        klass.operations = operations if operations.any?

        # will need to mark input/output for procedures that consume/produce since they're kind of black boxes
        klass.procedure = blk if block_given?
        klass.input = input # if input.any?
        klass.output = output

        klass
      end

      def perform(worker:, context:)
        if self.procedure
          perform_procedure(worker: worker, context: context)
        elsif self.operations
          perform_operations(context: context)
        else
          raise "no procedure or operation for activity #{self.name}"
        end
      end

      def perform_procedure(worker:, context:)
        self.procedure.call(activity: self, worker: worker, context: context)
      end

      def perform_operations(context:)
        return false if operations.nil?
        performable_operation = operations.detect do |operation|
          operation.input.can_take?(context.inventory)
        end

        if performable_operation
          performable_operation.input.consume!(context.inventory)
          performable_operation.output.produce!(context.inventory)
        end
      end
    end
  end
end
