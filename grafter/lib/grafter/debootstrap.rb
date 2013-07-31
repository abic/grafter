require 'fileutils'
require 'open-uri'

module Grafter

  class Debootstrap

    def initialize(target, suite='precise', mirror='http://archive.ubuntu.com/ubuntu')
      @suite, @target, @mirror = suite, target, mirror
      @quick_mirror = 'http://pkg.home.ophymx.com/ubuntu/mirror/us.archive.ubuntu.com/ubuntu/'
      @security_mirror = 'http://security.ubuntu.com/ubuntu'
    end

    def install
      run('debootstrap', suite, target, quick_mirror)
      update_source_list
      clear_apt_lists
      reconfigure_locale
      reconfigure_timezone
      dist_upgrade
      install_curl
    end

    private
    attr_reader :suite, :target, :mirror, :quick_mirror, :security_mirror

    def dist_upgrade
      Chroot.new(target).use do |chroot|
        chroot.run('apt-get', 'dist-upgrade')
      end
    end

    def reconfigure_locale
      open_in_target('/etc/default/locale', 'w+') { |f| f.puts 'LANG="en_US.UTF-8"' }
      Chroot.new(target).use do |chroot|
        chroot.run('localedef', '-i', 'en_US', '-f', 'UTF-8', 'en_US.UTF-8')
      end
    end

    def reconfigure_timezone
      open_in_target('/etc/timezone', 'w+') { |f| f.puts 'UTC' }
      Chroot.new(target).use do |chroot|
        chroot.run('dpkg-reconfigure', '-fnoninteractive', '-pcritical', 'tzdata')
      end
    end

    def clear_apt_lists
      FileUtils.rm_rf(Dir.glob(path_in_target('/var/lib/apt/lists/*')))
    end

    def update_source_list
      open_in_target('/etc/apt/sources.list', 'w+') do |f|
        f.puts "deb #{mirror} #{suite} main universe multiverse"
        f.puts "deb #{mirror} #{suite}-updates main universe multiverse"
        f.puts "deb #{security_mirror} #{suite}-security main universe multiverse"
      end
    end

    def install_curl
      Chroot.new(target).use do |chroot|
        chroot.run('apt-get', '-qq', 'update')
        chroot.run('apt-get', '-qq', 'install', 'curl')
      end
    end
  end
end
