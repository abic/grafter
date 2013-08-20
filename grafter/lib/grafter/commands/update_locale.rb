require 'grafter/commands/base'

module Grafter
  module Commands
    class UpdateLocale < Base
      execute 'update-locale'

      arg :key_pair
    end
  end
end
