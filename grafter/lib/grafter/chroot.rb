require 'grafter/commands/mount'
require 'grafter/commands/umount'

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
      Command.new([env, 'chroot', target, *args, options.merge(unsetenv_others: true)]).run
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
