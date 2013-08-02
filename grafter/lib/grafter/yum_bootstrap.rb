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
      FileUtils.mkdir_p(path_in_target('/var/lib/rpm'))
      run(['rpm', '--root', target, '--rebuilddb'])
      run(['rpm', '--root', target, '-i', '--nodeps', release_rpm])
      with_bind_from_target('/etc/pki') do
        run(['yum', '--installroot', target, '-y', 'install', 'yum'])
      end

      FileUtils.cp('/etc/resolv.conf', path_in_target('/etc/resolv.conf'))
      using_chroot do |chroot|
        chroot.run(['rpm', '-i', '--nodeps', release_rpm])
        chroot.run(%w(yum -y groupinstall Base))
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
      run(['mount', '-o', 'bind', path_in_target(dir), dir])
      yield
    ensure
      run(['umount', dir])
      FileUtils.rmdir(dir) unless had_dir
    end

    private
    attr_reader :target, :release_rpm, :epel_release_rpm
  end
end
