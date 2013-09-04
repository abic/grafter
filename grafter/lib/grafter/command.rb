require 'logger'

module Grafter
  class Command
    def initialize(args)
      @args = args
    end

    def run
      Logger.new($stderr).info("exec: #{args.reject { |arg| arg.is_a?(Hash) }.join(' ')}")
      system(*args) || fail("system('#{args.join("', '")}') failed")
    end

    private
    attr_reader :args
  end
end
