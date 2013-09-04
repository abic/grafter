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

    def run(command)
      env = ENV.to_hash.select { |k| %w(TERM LANG).include?(k) }.merge(
        'HOME' => '/root',
        'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
      )
      options = { unsetenv_others: true }
      Commands::Chroot.new(target, command).run(env: env, options: options)
    end

    private
    attr_reader :target

    def mount(device)
      dir = File.join(target, device)
      Commands::Mount.new(device, dir, bind: true).run
    end

    def unmount(device)
      dir = File.join(target, device)
      Commands::Umount.new(dir).run
    end
  end
end
