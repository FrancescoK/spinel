# A `**h` keyword splat into a method on a boxed receiver, alone or beside
# a positional splat -- BroadcastLogger's `logger.send(method, *args,
# **kwargs)` over its loggers. The dispatch recognised only a
# literal keyword hash; one carrying a `**h` fell back to the positional
# path, matched no arm, and the call raised NoMethodError at run time. The
# merged hash is built once ahead of the arms; a declared keyword parameter
# reads its key from it (its default when absent), a `**kwrest` takes the
# rest, and a callee with neither sees none of it.
class Plain
  def log(msg, tag: nil, level: :info) = "plain #{msg} #{tag.inspect} #{level}"
  def opts(**kw) = "plain opts #{kw.inspect}"
  def mixed(msg, tag: nil, **rest) = "plain mixed #{msg} #{tag.inspect} #{rest.inspect}"
  def bare(msg) = "plain bare #{msg}"
end
class Fancy
  def log(msg, tag: nil, level: :info) = "fancy #{msg.upcase} #{tag.inspect} #{level}"
  def opts(**kw) = "fancy opts #{kw.size}"
  def mixed(msg, tag: nil, **rest) = "fancy mixed #{msg} #{tag.inspect} #{rest.keys.inspect}"
  def bare(msg) = "fancy bare #{msg}"
end
class Broadcast
  def initialize = @sinks = [Plain.new, Fancy.new]
  def each_sink(&b) = @sinks.each(&b)
  def dispatch(method, *args, **kwargs)
    @sinks.map { |s| s.send(method, *args, **kwargs) }
  end
  def relay(method, ...) = dispatch(method, ...)
end
bc = Broadcast.new
h = { tag: :t, level: :warn }
bc.each_sink { |s| puts s.log("a", **h) }
bc.each_sink { |s| puts s.log("b", **{}) }
bc.each_sink { |s| puts s.log("c", tag: :lit, **{ level: :debug }) }
bc.each_sink { |s| puts s.opts(**h) }
bc.each_sink { |s| puts s.mixed("d", **h) }
args = ["e"]
bc.each_sink { |s| puts s.log(*args, **h) }
bc.each_sink { |s| puts s.bare(*args, **{}) }
puts bc.dispatch(:log, "f", tag: :dsp)
puts bc.dispatch(:bare, "g")
puts bc.relay(:log, "h", level: :error)
puts bc.relay(:opts, tag: :r)
