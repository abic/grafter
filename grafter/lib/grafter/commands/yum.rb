module Grafter
  module Commands
    class Yum
      def initialize(global_options={})
        @global_options = global_options
      end

      def install(package)
        ['yum', expand_global_options, '-y', 'install', package].flatten
      end

      def install_base
        %w(yum -y groupinstall Base)
      end

      private

      attr_reader :global_options

      def expand_global_options
        global_options[:root] ? ['--installroot', global_options[:root]] : []
      end
    end
  end
end
