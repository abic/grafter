module Grafter

  class Graft
    BASE_DIR = '/var/lib/grafter/grafts'

    def self.list
      Dir.glob(File.join(BASE_DIR, '*')).map { |f| File.basename(f) }
    end

    TYPES = {
      ubuntu: Debootstrap,
      centos: YumBootstrap
    }

    attr_reader :name, :type

    def initialize(name, type=:centos)
      @name = name
      @type = type
    end

    def install
      FileUtils.mkdir_p(BASE_DIR)
      TYPES.fetch(type).new(target).install
      Chef.new(target).install
    end

    # TODO
    #  ensure all binds unmounted
    def destroy
      FileUtils.rm_rf(target)
    end

    def chroot
      Chroot.new(target).use do |chroot|
        chroot.run('/bin/bash', '-l')
      end
    end

    def target
      File.join(BASE_DIR, name)
    end
  end
end
