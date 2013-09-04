require 'grafter/commands/command_wrapper'

module Grafter
  module Commands
    class Base
      class << self
        attr_reader :executable

        def execute(executable)
          @executable = executable
        end

        def args
          @args ||= []
        end

        def arg(name)
          args << name
        end

        def options
          @options ||= {}
        end

        def option(name, opts={})
          options[name] = opts
        end

        def flag(name, opts={})
          option(name, opts.merge(flag: true))
        end

        def subcommand(name, opts={}, &blk)
          command_class = Class.new(Base) do |klass|
            klass.execute opts.fetch(:command, name.to_s)
            blk.call(klass) if blk
          end

          define_method(name) do |*subcommand_args|
            CommandWrapper.new(command + command_class.new(*subcommand_args).command)
          end
          command_class
        end
      end

      def initialize(*args)
        @options = args.last.is_a?(Hash) ? args.pop : {}
        unless args.length == self.class.args.length
          raise ArgumentError.new(
            'wrong number of aruments (%s for %s)' %
            [args.length, self.class.args.length]
          )
        end
        @args = Hash[self.class.args.zip(args)]
      end

      def executable
        self.class.executable
      end

      def args
        @args.values_at(*self.class.args)
      end

      def options_args
        class_options = self.class.options
        class_options.keys.reduce([]) do |exec_args, option|
          class_option = class_options[option]
          if @options[option] || class_option[:default]
            exec_args << class_option.fetch(:arg, "--#{option}")
            unless class_option[:flag]
              exec_args << @options.fetch(option) { class_option[:default] }
            end
          end
          exec_args
        end
      end

      def run
        CommandWrapper.new(command).run
      end

      def command
        executable.split.concat(options_args).concat(args)
      end
    end
  end
end
