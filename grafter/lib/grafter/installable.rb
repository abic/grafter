module Grafter
  module Installable
    def path_in_target(path)
      File.join(target, path)
    end

    def open_in_target(file, mode)
      File.open(path_in_target(file), mode) do |file|
        yield file
      end
    end

    def run(*args)
      Command.new(*args).run
    end
  end
end
