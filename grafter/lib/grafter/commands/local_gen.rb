require 'grafter/commands/base'

module Grafter
  module Commands
    class LocaleGen < Base
      execute 'locale-gen'
      arg :locale
    end
  end
end
