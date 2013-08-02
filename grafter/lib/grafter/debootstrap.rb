require 'fileutils'
require 'open-uri'

module Grafter
  class Debootstrap
    include Graftable

    def initialize(target, suite='precise', mirror='http://archive.ubuntu.com/ubuntu')
      @suite, @target, @mirror = suite, target, mirror
      @quick_mirror = @mirror
      @security_mirror = 'http://security.ubuntu.com/ubuntu'
    end

    def install
      run(['debootstrap', suite, target, quick_mirror])
      update_source_list
      reconfigure_locale
      reconfigure_timezone
      dist_upgrade
      install_curl
    end

    private
    attr_reader :suite, :target, :mirror, :quick_mirror, :security_mirror

    def update_source_list
      FileUtils.rm_rf(Dir.glob(path_in_target('/var/lib/apt/lists/*')))
      open_in_target('/etc/apt/sources.list', 'w+') do |f|
        f.write(<<-EOF)
          deb #{mirror} #{suite} main universe multiverse
          deb #{mirror} #{suite}-updates main universe multiverse
          deb #{security_mirror} #{suite}-security main universe multiverse
        EOF
      end
    end

    def reconfigure_locale
      using_chroot do |chroot|
        chroot.run(%w(locale-gen en_US.UTF-8))
        chroot.run(%w(update-locale LANG=en_US.UTF-8))
        chroot.run(dpkg_reconfigure('libc6'))
        chroot.run(dpkg_reconfigure('locales'))
      end
    end

    def reconfigure_timezone
      open_in_target('/etc/timezone', 'w+') { |f| f.puts 'UTC' }
      using_chroot do |chroot|
        chroot.run(dpkg_reconfigure('tzdata'))
      end
    end

    def dist_upgrade
      using_chroot do |chroot|
        chroot.run(apt_get(%w(update)))
        #chroot.run(apt_get(%w(install upstart)))
        #chroot.run(apt_get(%w(dist-upgrade)))
      end
    end

    def install_curl
      using_chroot do |chroot|
        chroot.run(apt_get(%w(install curl)))
      end
    end

    def apt_get(args)
      %w(apt-get -y).concat(args)
    end

    def dpkg_reconfigure(package)
      ['dpkg-reconfigure', '-fnoninteractive', '-pcritical', package]
    end
  end
end
