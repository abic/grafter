require 'grafter'
require 'thor'

module Grafter
  module Cli
    class Main < Thor
      desc 'install NAME', 'install a debootstrapped chroot'
      option :type, default: 'ubuntu', aliases: '-t'
      def install(name)
        Graft.new(name, options[:type].to_sym).install
      end

      desc 'destroy NAME', 'destroy a debootstrapped chroot'
      def destroy(name)
        Graft.new(name).destroy
      end

      desc 'chroot NAME', 'chroot into graft'
      def chroot(name)
        Graft.new(name).chroot
      end

      desc 'list', 'list chroots'
      def list
        puts Graft.list
      end
    end
  end
end
