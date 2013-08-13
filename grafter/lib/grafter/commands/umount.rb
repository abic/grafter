module Grafter
  module Commands
    class Umount
      def initialize(dir)
        @dir = dir
      end

      def command
        ['umount', dir]
      end

      private

      attr_reader :dir
    end
  end
end
