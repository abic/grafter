module Grafter
  module Commands
    class UpdateLocale
      def update(locale)
        ['update-locale', "LANG=#{locale}"]
      end
    end
  end
end
