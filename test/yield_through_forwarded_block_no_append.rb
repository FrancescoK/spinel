# A String yielded into a block forwarded with `&` through methods of the
# same name, or through a call on a poly receiver, is not refused when no
# block it can reach appends to it.

class Machine
  def restore(state) = state
  def restore_snapshot(path, &) = Snapshot.restore(self, path, &)
  def load(&) = Snapshot.load("x", &)
end

class Image
  def restore(machine, &)
    machine.restore(1)
    tell(["one", "two"], &)
  end

  def load(&)
    tell(["three"], &)
    self
  end

  def tell(lines) = lines.each { |line| yield line }
end

module Snapshot
  module_function

  def restore(machine, path, &) = Image.new.restore(machine, &)
  def load(path, &) = Image.new.load(&)
end

class Log
  def on_line(&blk) = @blk = blk
  def emit(s) = @blk.call(s)
end

m = ARGV.empty? ? Machine.new : 42
m.restore_snapshot("x") { |line| puts line }
m.load { |line| puts line }

log = Log.new
log.on_line { |s| s << "!" }
t = +"a"
log.emit(t)
p t
