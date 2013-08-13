module Grafter
  module Commands
    class Chroot
      def initialize(target)
        @target = target
      end

      def command(exec_args)
        ['chroot', target, exec_args].flatten
      end

      private

      attr_reader :target
    end
  end
end
