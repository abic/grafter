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
        'LC_ALL' => 'C',
        'HOME' => '/root',
        'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
      )
      Command.new([env, 'chroot', target, *args, options.merge(unsetenv_others: true)]).run
    end

    private
    attr_reader :target

    def mount(fs)
      Command.new(['mount', '-o', 'bind', MOUNTS.fetch(fs), File.join(target, MOUNTS.fetch(fs))]).run
    end

    def unmount(fs)
      Command.new(['umount', File.join(target, MOUNTS.fetch(fs))]).run
    end
  end
end
