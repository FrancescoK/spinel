# `Kernel.require "lib"` is the same require as the bare one: activesupport's
# DeprecatedConstantProxy#initialize spells it that way. The textual require
# resolver skipped a `require` preceded by a dot -- it would be some object's
# method -- so the library was never spliced and the call was refused. A
# `Kernel.` (or `::Kernel.`) qualifier is the bare form; `obj.require` stays
# a method call.
class Reg
  def initialize(s)
    Kernel.require "json"
    @h = JSON.parse(s)
  end
  def size = @h.size
  def get(k) = @h[k]
end
r = Reg.new('{"a": 1, "b": [2]}')
p r.size, r.get("b")
::Kernel.require "set"
p Set.new([1, 1, 2]).size
p(Kernel.require("json"))
