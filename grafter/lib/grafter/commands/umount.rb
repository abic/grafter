require 'grafter/commands/base'

module Grafter
  module Commands
    class Umount < Base
      execute 'umount'

      arg :dir
    end
  end
end
