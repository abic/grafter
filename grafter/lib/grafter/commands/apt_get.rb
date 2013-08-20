require 'grafter/commands/base'

module Grafter
  module Commands
    class AptGet < Base
      execute 'apt-get'
      flag :yes, default: true

      subcommand :dist_upgrade, command: 'dist-upgrade'

      subcommand :update

      subcommand :install do |s|
        s.arg :package
      end
    end
  end
end
