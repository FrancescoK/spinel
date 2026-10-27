# `Kernel.warn` inside a method of the same name is Kernel's warn, not the
# method itself. The Kernel receiver was dropped as for any Kernel
# function, and the bare call then took the program's own method of the
# name: `def warn(m) = Kernel.warn(...)` called itself until the stack ran
# out, and a top-level `def format` took the arguments of `Kernel.format`.
class Log
  def warn(m) = Kernel.warn("log: #{m}")
  def abort(m) = Kernel.abort("log: #{m}")
  def puts(m) = Kernel.puts("[#{m}]")
  def format(f, *a) = "<" + Kernel.format(f, *a) + ">"
end

def warn(m) = Kernel.warn("top: #{m}")
def sprintf(f, *a) = "{" + Kernel.sprintf(f, *a) + "}"

log = Log.new
log.warn("hi")
warn("there")
log.puts("out")
Kernel.puts log.format("%03d", 7)
Kernel.puts sprintf("%.1f", 2.5)
begin
  log.abort("bye")
rescue SystemExit => e
  Kernel.puts "exit #{e.status}"
end
