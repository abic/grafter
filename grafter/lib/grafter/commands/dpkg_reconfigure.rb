module Grafter
  module Commands
    class DpkgReconfigure
      def reconfigure(package)
        ['dpkg-reconfigure', '-fnoninteractive', '-pcritical', package]
      end
    end
  end
end
