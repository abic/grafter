require 'fileutils'
require 'open-uri'

require 'grafter/commands/debootstrap'
require 'grafter/commands/local_gen'
require 'grafter/commands/update_locale'
require 'grafter/commands/dpkg_reconfigure'
require 'grafter/commands/apt_get'

module Grafter
  class Debootstrap
    def initialize(target, suite='precise', mirror='http://archive.ubuntu.com/ubuntu')
      @suite, @target, @mirror = suite, target, mirror
      @security_mirror = 'http://security.ubuntu.com/ubuntu'
    end

    def install
      Command.new(Commands::Debootstrap.new(suite, target, mirror).command).run
      update_source_list
      reconfigure_locale
      reconfigure_timezone
      dist_upgrade
      install_curl
    end

    private
    attr_reader :suite, :target, :mirror, :security_mirror

    def update_source_list
      FileUtils.rm_rf(Dir.glob(File.join(target, '/var/lib/apt/lists/*')))
      File.open(File.join(target, '/etc/apt/sources.list'), 'w+') do |file|
        file.write(<<-EOF)
          deb #{mirror} #{suite} main universe multiverse
          deb #{mirror} #{suite}-updates main universe multiverse
          deb #{security_mirror} #{suite}-security main universe multiverse
        EOF
      end
    end

    def reconfigure_locale
      Chroot.new(target).use do |chroot|
        chroot.run Commands::LocaleGen.new('en_US.UTF-8').command
        chroot.run Commands::UpdateLocale.new('LANG=en_US.UTF-8').command
        chroot.run Commands::DpkgReconfigure.new('libc6').command
        chroot.run Commands::DpkgReconfigure.new('locales').command
      end
    end

    def reconfigure_timezone
      File.open(File.join(target, '/etc/timezone'), 'w+') { |f| f.puts 'UTC' }
      Chroot.new(target).use do |chroot|
        chroot.run Commands::DpkgReconfigure.new('tzdata').command
      end
    end

    def dist_upgrade
      Chroot.new(target).use do |chroot|
        chroot.run Commands::AptGet.new.update
      end
    end

    def install_curl
      Chroot.new(target).use do |chroot|
        chroot.run Commands::AptGet.new.install('curl')
      end
    end
  end
end
