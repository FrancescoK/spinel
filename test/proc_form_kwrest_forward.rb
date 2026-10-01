# A `...` forwarder whose target hands the block on -- BroadcastLogger's
# `def info(...) = dispatch(:info, ...)`, where dispatch passes the block to
# each logger's `send` -- is emitted in its proc form, since the send's arms
# reach it on a boxed receiver. The clone typed its parameters boxed, the
# `**__fwk` keyword rest among them, and the forward of a boxed value into
# dispatch's **kwargs was refused as a non-symbol-keyed hash. The clone's
# keyword rest is a symbol-keyed hash by construction, as its `*rest` is an
# Array.
class Sink
  def initialize = @lines = []
  def info(msg = nil, &block) = @lines << (block ? block.call : msg)
  def add(sev, msg = nil) = @lines << [sev, msg]
  def lines = @lines
end
class Tee < Sink
  def info(msg = nil, &block) = super("tee:#{block ? block.call : msg}")
end
class Broadcast
  def initialize(*sinks) = @sinks = sinks
  def info(...)
    dispatch(:info, ...)
  end
  def add(...) = dispatch(:add, ...)
  private
    def dispatch(method, *args, **kwargs, &block)
      @sinks.map { |s| s.send(method, *args, **kwargs, &block) }.first
    end
end
a, b = Sink.new, Tee.new
bc = Broadcast.new(a, b)
bc.info("hello")
bc.info { "from block" }
bc.add(1, "m")
p a.lines, b.lines
