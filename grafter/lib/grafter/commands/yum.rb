require 'grafter/commands/base'

module Grafter
  module Commands
    class Yum < Base
      execute 'yum'
      flag :yes, arg: '-y', default: true
      option :root, arg: '--installroot'

      subcommand :install do |s|
        s.arg :package
      end

      subcommand :group_install, command: 'groupinstall' do |s|
        s.arg :group
      end
    end
  end
end
