require 'grafter/commands/command_wrapper'

module Grafter
  module Commands
    class Chroot
      def initialize(target, subcommand)
        @target = target
        @subcommand = subcommand
      end

      def run(options={})
        CommandWrapper.new(['chroot', target, subcommand.command].flatten).run(options)
      end

      private

      attr_reader :target, :subcommand
    end
  end
end
