require 'grafter/commands/base'

module Grafter
  module Commands
    class Rpm < Base
      execute 'rpm'
      option :root

      subcommand :install, command: '-i' do |s|
        s.flag :nodeps, default: true
        s.arg :rpm_file
      end

      subcommand :rebuilddb, command: '--rebuilddb'
    end
  end
end
