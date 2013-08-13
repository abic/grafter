module Grafter
  module Commands
    class AptGet
      def dist_upgrade
        ['apt-get', '-y', 'dist-upgrade']
      end

      def update
        ['apt-get', '-y', 'update']
      end

      def install(package)
        ['apt-get', '-y', 'install', package]
      end
    end
  end
end
