module Grafter
  module Commands
    class Rpm
      def initialize(global_options={})
        @global_options = global_options
      end

      def install(rpm_file_location)
        ['rpm', expand_global_options, '-i', '--nodeps', rpm_file_location].flatten
      end

      def rebuilddb
        ['rpm', expand_global_options, '--rebuilddb'].flatten
      end

      private

      attr_reader :global_options

      def expand_global_options
        global_options[:root] ? ['--root', global_options[:root]] : []
      end
    end
  end
end
