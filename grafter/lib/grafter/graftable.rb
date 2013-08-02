module Grafter
  module Graftable
    def path_in_target(path)
      File.join(target, path)
    end

    def open_in_target(file, mode)
      File.open(path_in_target(file), mode) do |file|
        yield file
      end
    end

    def run(args)
      Command.new(args).run
    end

    def using_chroot
      Chroot.new(target).use do |chroot|
        yield chroot
      end
    end
  end
end
