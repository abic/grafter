module Grafter
  class Chef
    def initialize(target)
      @target = target
    end

    def install
      omnibus_script = '/var/tmp/omnibus-install.sh'

      open('https://www.opscode.com/chef/install.sh') do |f|
        File.write(file_in_target(omnibus_script), f.read)
      end
      FileUtils.chmod(0700, file_in_target(omnibus_script))

      Chroot.new(target).use do |chroot|
        chroot.run(omnibus_script)
      end
    ensure
      FileUtils.rm_f(file_in_target(omnibus_script))
    end

    private
    attr_reader :target

    def file_in_target(file)
      File.join(target, file)
    end
  end
end

