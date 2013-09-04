require 'grafter/commands/mount'
require 'grafter/commands/umount'
require 'grafter/commands/chroot'

module Grafter
  class Chroot
    def initialize(target)
      @target = target
    end

    def use
      mount '/proc'
      mount '/sys'
      mount '/dev'
      mount '/dev/pts'

      yield self
    ensure
      unmount '/dev/pts'
      unmount '/dev'
      unmount '/sys'
      unmount '/proc'
    end

    def run(args, options={})
      env = ENV.to_hash.select { |k| %w(TERM LANG).include?(k) }.merge(
        'HOME' => '/root',
        'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
      )
      env_options = options.merge(unsetenv_others: true)
      exec_args = Commands::Chroot.new(target).command(args)
      Command.new([env, exec_args, env_options].flatten).run
    end

    private
    attr_reader :target

    def mount(device)
      dir = File.join(target, device)
      exec_args = Commands::Mount.new(device, dir, bind: true).command
      Command.new(exec_args).run
    end

    def unmount(device)
      dir = File.join(target, device)
      exec_args = Commands::Umount.new(dir).command
      Command.new(exec_args).run
    end
  end
end
