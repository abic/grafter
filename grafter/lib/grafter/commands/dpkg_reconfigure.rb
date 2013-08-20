require 'grafter/commands/base'

module Grafter
  module Commands
    class DpkgReconfigure < Base
      execute 'dpkg-reconfigure'
      flag :non_interactive, arg: '-fnoninteractive', default: true
      flag :critical, arg: '-pcritical', default: true

      arg :package
    end
  end
end
