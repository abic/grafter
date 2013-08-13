require 'grafter/commands/rpm'
require 'grafter/commands/yum'
require 'grafter/commands/mount'
require 'grafter/commands/umount'

module Grafter
  class YumBootstrap
    include Graftable

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
      FileUtils.mkdir_p(path_in_target('/var/lib/rpm'))
      run Commands::Rpm.new(root: target).rebuilddb
      run Commands::Rpm.new(root: target).install(release_rpm)
      with_bind_from_target('/etc/pki') do
        run Commands::Yum.new(root: target).install('yum')
      end
    end

    def install_inside_chroot
      FileUtils.cp('/etc/resolv.conf', path_in_target('/etc/resolv.conf'))
      using_chroot do |chroot|
        chroot.run Commands::Rpm.new.install(release_rpm)
        chroot.run Commands::Yum.new.install_base
      end
      # install via chef
      # chroot.run('rpm', '-i', '--nodeps', epel_release_rpm)
      # chroot.run('yum', '-y', 'groupinstall', 'Development Tools')
      # packages = %w(libyaml-devel libxslt-devel zlib-devel openssl-devel sudo readline-devel libffi-devel openssh-server)
      # chroot.run('yum', '-y', 'install', *packages)
    end

    def with_bind_from_target(dir)
      had_dir = Dir.exists?(dir)
      FileUtils.mkdir(dir) unless had_dir
      run Commands::Mount.new(path_in_target(dir), dir, bind: true).command
      yield
    ensure
      run Commands::Umount.new(path_in_target(dir)).command
      FileUtils.rmdir(dir) unless had_dir
    end
  end
end
