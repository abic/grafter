require 'grafter/commands/base'

module Grafter
  module Commands
    class Mount < Base
      execute 'mount'
      flag :bind, arg: '-obind'

      arg :device
      arg :dir
    end
  end
end
