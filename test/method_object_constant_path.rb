# `Outer::Mod.method(:m)` binds the module's class method, as `Mod.method(:m)`
# does; a constant-path receiver was not recognized and the Method object
# could not be called.
module SQ
  module FFI
    module CApi
      def self.fin(x) = x * 2
    end
  end
  class St
    def initialize
      @m = FFI::CApi.method(:fin)
    end
    def go = @m.call(21)
  end
end
p SQ::St.new.go
