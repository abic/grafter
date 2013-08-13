require 'grafter/commands/mount'
require 'grafter/commands/umount'
require 'grafter/commands/chroot'

module Grafter
  class Chroot

    MOUNTS = {
      proc: '/proc',
      sysfs: '/sys',
      dev: '/dev',
      devpts: '/dev/pts'
    }

    def initialize(target)
      @target = target
    end

    def use
      mount :proc
      mount :sysfs
      mount :dev
      mount :devpts

      yield self
    ensure
      unmount :devpts
      unmount :dev
      unmount :sysfs
      unmount :proc
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

    def mount(fs)
      device = MOUNTS.fetch(fs)
      dir = File.join(target, device)
      exec_args = Commands::Mount.new(device, dir, bind: true).command
      Command.new(exec_args).run
    end

    def unmount(fs)
      device = MOUNTS.fetch(fs)
      dir = File.join(target, device)
      exec_args = Commands::Umount.new(dir).command
      Command.new(exec_args).run
    end
  end
end
