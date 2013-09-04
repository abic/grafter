require 'logger'

module Grafter
  module Commands
    class CommandWrapper
      def initialize(args)
        @args = args
      end

      def run(options={})
        Logger.new($stderr).info("exec: #{args.reject { |arg| arg.is_a?(Hash) }.join(' ')}")
        exec_args = [options[:env], args, options[:options]].compact.flatten
        system(*exec_args) || fail("system('#{args.join("', '")}') failed")
      end

      def command
        args
      end

      private
      attr_reader :args
    end
  end
end
