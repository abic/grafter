require 'fileutils'
require 'open-uri'

require 'grafter/commands/debootstrap'
require 'grafter/commands/local_gen'
require 'grafter/commands/update_locale'
require 'grafter/commands/dpkg_reconfigure'
require 'grafter/commands/apt_get'

module Grafter
  class Debootstrap
    include Graftable

    def initialize(target, suite='precise', mirror='http://archive.ubuntu.com/ubuntu')
      @suite, @target, @mirror = suite, target, mirror
      @security_mirror = 'http://security.ubuntu.com/ubuntu'
    end

    def install
      run Commands::Debootstrap.new.debootstrap(suite, target, mirror)
      update_source_list
      reconfigure_locale
      reconfigure_timezone
      dist_upgrade
      install_curl
    end

    private
    attr_reader :suite, :target, :mirror, :security_mirror

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
        chroot.run Commands::LocaleGen.new.generate('en_US.UTF-8')
        chroot.run Commands::UpdateLocale.new.update('en_US.UTF-8')
        chroot.run Commands::DpkgReconfigure.new.reconfigure('libc6')
        chroot.run Commands::DpkgReconfigure.new.reconfigure('locales')
      end
    end

    def reconfigure_timezone
      open_in_target('/etc/timezone', 'w+') { |f| f.puts 'UTC' }
      using_chroot do |chroot|
        chroot.run Commands::DpkgReconfigure.new.reconfigure('tzdata')
      end
    end

    def dist_upgrade
      using_chroot do |chroot|
        chroot.run Commands::AptGet.new.update
      end
    end

    def install_curl
      using_chroot do |chroot|
        chroot.run Commands::AptGet.new.install('curl')
      end
    end
  end
end
