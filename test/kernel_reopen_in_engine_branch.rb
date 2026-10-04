# A module Kernel reopening inside a top-level engine check (one engine's
# shims) hoists its defs as one at the top level does (#7204).
if RUBY_ENGINE == "spinel"
  module Kernel
    private

    def exec(*args)
      puts "shim exec #{args.inspect}"
    end
  end
else
  module Kernel
    private

    def exec(*args)
      puts "shim exec #{args.inspect}"
    end
  end
end

def logs
  exec "kubectl logs -f"
end

logs

unless RUBY_ENGINE == "jruby"
  module Kernel
    def shout(s) = puts(s.upcase)
  end
end
shout "loud"
