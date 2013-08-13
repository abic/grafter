module Grafter
  module Commands
    class Mount
      def initialize(device, dir, options={})
        @device = device
        @dir = dir
        @global_options = options
      end

      def command
        ['mount', expand_global_options, device, dir].flatten
      end

      private

      attr_reader :device, :dir, :global_options

      def expand_global_options
        global_options[:bind] ? ['-o', 'bind'] : []
      end
    end
  end
end
