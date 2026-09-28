class Probe
  def reflect(obj)
    return :aot if RUBY_ENGINE == "spinel"
    (class << obj; self; end).instance_methods(false)
  end

  def other(x)
    return x * 2 unless RUBY_ENGINE != "spinel"
    Object.new.singleton_class.class
  end

  def keep(x)
    return x if RUBY_ENGINE == "jruby"
    x + 1
  end
end
p Probe.new.reflect(Object.new)
p Probe.new.other(3)
p Probe.new.keep(4)
