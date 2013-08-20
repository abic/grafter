require 'grafter/commands/base'

module Grafter
  module Commands
    class Debootstrap < Base
      execute 'debootstrap'
      arg :suite
      arg :target
      arg :mirror
    end
  end
end
