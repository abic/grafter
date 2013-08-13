module Grafter
  module Commands
    class Debootstrap
      def debootstrap(suite, target, quick_mirror)
        ['debootstrap', suite, target, quick_mirror]
      end
    end
  end
end
