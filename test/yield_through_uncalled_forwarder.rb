# A String yielded into a block forwarded with `&` is not refused for a
# forwarding method nothing calls: it is passed no block.

Report = Data.define(:ignored)

class C64
  def restore(state) = state
  def restore_snapshot(path, &) = Snapshot.restore(self, path, &)
end

class Vic20
  def restore_snapshot(path, &) = Snapshot.restore(self, path, &)
end

class Image
  def initialize(own) = @own = own

  def restore(machine, &)
    report = @own ? restore_state(machine) : Report.new(ignored: ["foreign"])
    tell(report, &)
  end

  def tell(report)
    report.ignored.each { |line| block_given? ? yield(line) : puts("left out: #{line}") }
  end

  def restore_state(machine)
    opening { machine.restore(1) }
    Report.new(ignored: ["own"])
  end

  def opening = yield
end

module Snapshot
  module_function

  def restore(machine, path, &) = Image.new(path.end_with?(".bl")).restore(machine, &)
end

class Log
  def on_line(&blk) = @blk = blk
  def emit(s) = @blk.call(s)
end

p C64.new.restore(2)
Image.new(true).restore(C64.new)
Image.new(false).restore(C64.new)
log = Log.new
log.on_line { |s| s << "!" }
t = +"a"
log.emit(t)
p t
