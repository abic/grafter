require 'grafter'
require 'thor'

module Grafter
  module Cli

    class Roots < Thor
      desc 'create NAME', 'install a debootstrapped chroot'
      option :type, default: 'ubuntu', aliases: '-t'
      def create(name)
        Root.new(name, options[:type].to_sym).create
      end

      desc 'destroy NAME', 'destroy a debootstrapped chroot'
      def destroy(name)
        Root.new(name).destroy
      end

      desc 'list', 'list chroots'
      def list
        puts Root.list
      end
    end

    class Main < Thor
      desc 'roots SUBCOMMAND ...ARGS', 'manage creation of roots'
      subcommand 'roots', Roots

      #desc 'chroot NAME', 'chroot into graft'
      #def chroot(name)
      #  Graft.new(name).chroot
      #end

      #desc 'graft GRAFT_FILE', 'grafts stems onto a root'
      #def graft(file)
      #  Graft.new(file).run
      #end
    end
  end
end
