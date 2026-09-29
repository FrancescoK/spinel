# `NS::Reg.new` (a constant PATH receiver) in a class body, of a class whose
# initialize takes an optional parameter and a &block: the call rendered the
# defaulted parameter but not the absent block, a C arity error; a plain
# `Reg.new` at the same spot passed NULL for it.
module NS
  class Reg
    def initialize(options = nil, &default_proc)
      @h = {}
      @default_proc = default_proc
    end
    def [](k) = @h.key?(k) ? @h[k] : (@default_proc ? @default_proc.call(self, k) : nil)
    def []=(k, v)
      @h[k] = v
    end
    def key?(k) = @h.key?(k)
  end
end
class Holder
  @reg = NS::Reg.new
  @en = nil
  def self.instance(locale = :en)
    return @en ||= "EN" if locale == :en
    @reg[locale] ||= locale.to_s
  end
  def self.known?(k) = @reg.key?(k)
end
p Holder.instance, Holder.instance(:fr), Holder.known?(:fr), Holder.known?(:de)
