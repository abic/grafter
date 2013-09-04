module Grafter
  class Root
    BASE_DIR = '/var/lib/grafter/roots'

    def self.list
      Dir.entries(BASE_DIR).reject { |f| f =~ /^\./ }
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

    def create
      FileUtils.mkdir_p(BASE_DIR)
      TYPES.fetch(type).new(target).install
    end

    # TODO
    #  ensure all binds unmounted
    def destroy
      FileUtils.rm_rf(target)
    end

    def chroot
      Chroot.new(target).run('/bin/bash', '-l')
    end

    def target
      File.join(BASE_DIR, name)
    end
  end
end
