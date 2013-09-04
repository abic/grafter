module Grafter
  class Chef
    def initialize(target)
      @target = target
    end

    def install
      omnibus_script = '/var/tmp/omnibus-install.sh'
      omnibus_script_in_target = File.join(target, omnibus_script)

      open('https://www.opscode.com/chef/install.sh') do |remote|
        File.open(omnibus_script_in_target, 'w+') do |local|
          local.write(remote.read)
        end
      end
      FileUtils.chmod(0700, omnibus_script_in_target)

      Chroot.new(target).run([omnibus_script])
    ensure
      FileUtils.rm_f(omnibus_script_in_target)
    end

    private
    attr_reader :target
  end
end
