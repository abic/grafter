module Grafter
  class Chef
    include Graftable

    def initialize(target)
      @target = target
    end

    def install
      omnibus_script = '/var/tmp/omnibus-install.sh'

      open('https://www.opscode.com/chef/install.sh') do |remote|
        open_in_target(omnibus_script, 'w+') do |local|
          local.write(remote.read)
        end
      end
      FileUtils.chmod(0700, path_in_target(omnibus_script))

      using_chroot do |chroot|
        chroot.run([omnibus_script])
      end
    ensure
      FileUtils.rm_f(path_in_target(omnibus_script))
    end

    private
    attr_reader :target
  end
end

