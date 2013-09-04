require 'grafter/commands/rpm'
require 'grafter/commands/yum'
require 'grafter/commands/mount'
require 'grafter/commands/umount'

module Grafter
  class YumBootstrap

    def initialize(target)
      @target = target
      @repo = 'http://mirror.centos.org/centos/6/os'
      @release_rpm = 'http://mirror.centos.org/centos/6/os/x86_64/Packages/centos-release-6-4.el6.centos.10.x86_64.rpm'
      @epel_release_rpm = 'http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm'
    end

    def install
      install_outside_chroot
      install_inside_chroot
    end

    private

    attr_reader :target, :release_rpm, :epel_release_rpm

    def install_outside_chroot
      FileUtils.mkdir_p(File.join(target, '/var/lib/rpm'))
      Commands::Rpm.new(root: target).rebuilddb.run
      Commands::Rpm.new(root: target).install(release_rpm).run
      with_bind_from_target('/etc/pki') do
        Commands::Yum.new(root: target).install('yum').run
      end
    end

    def install_inside_chroot
      FileUtils.cp('/etc/resolv.conf', File.join(target, '/etc/resolv.conf'))
      Chroot.new(target).use do |chroot|
        chroot.run Commands::Rpm.new.install(release_rpm)
        chroot.run Commands::Yum.new.group_install('Base')
      end
    end

    def with_bind_from_target(dir)
      bind_dir = File.join(target, dir)
      had_dir = Dir.exists?(dir)
      FileUtils.mkdir(dir) unless had_dir
      Commands::Mount.new(bind_dir, dir, bind: true).run
      yield
    ensure
      Commands::Umount.new(bind_dir).run
      FileUtils.rmdir(dir) unless had_dir
    end
  end
end
