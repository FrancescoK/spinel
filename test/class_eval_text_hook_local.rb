# class_eval text in an included hook runs in the hook's frame: it reads
# and writes the hook's locals, a write is the hook's after the text, each
# includer's hook call has its own locals, a block parameter of the same
# name shadows the hook's local only inside its block, and a local the
# hook assigns after the text is nil there.
module Hook
  def self.included(base)
    x = base.name.size
    t = 1
    base.class_eval do
      %w[a b].each { |x| class_eval "def m_#{x} = :#{x}" }
      class_eval "N = x * 2"
      class_eval "t += 10; T = t"
      class_eval "L = y.inspect"
    end
    p t
    y = 3
  end
end

class Ab
  include Hook
end

class Abcd
  include Hook
end

p Ab::N, Abcd::N, Ab::T
p Ab.new.m_a, Abcd.new.m_b
p Ab::L
