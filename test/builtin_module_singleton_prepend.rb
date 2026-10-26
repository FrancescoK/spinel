# A builtin module's singleton class takes a mixin, at the top level and from
# a method the file calls as it loads (sqlite3's fork safety hooks
# `::Process.singleton_class.prepend(CoreExt)` from `ForkSafety.hook!`).
module MathExt
  def twice(x) = x * 2
end
::Math.singleton_class.prepend(MathExt)

module Store
  module ForkSafety
    module CoreExt
      def _fork
        pid = super
        pid
      end

      def fork_hooked? = true
    end

    class << self
      def hook!
        ::Process.singleton_class.prepend(CoreExt)
      end
    end
  end
end
Store::ForkSafety.hook!

p Math.twice(21)
p Math.sqrt(16)
p Process.fork_hooked?
p Process.respond_to?(:_fork)
p Process.pid > 0
