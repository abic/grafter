module Grafter
  module Commands
    class LocaleGen
      def generate(locale)
        ['locale-gen', locale]
      end
    end
  end
end
