# A library CRuby loads before the program runs (RbConfig, ThreadGroup,
# MonitorMixin, Process.detach, ObjectSpace's finalizers) is spliced in when
# the program names it and does not open the module itself. A `module X`
# in a comment, an embedded document, a heredoc or a string literal opens
# nothing, but it was taken for the program's own definition: the library
# was left out and its constants and methods were missing.
#
# A documentation comment:
#
#   module RbConfig
#   module ThreadGroup
#   module MonitorMixin
#   module Process
#   module ObjectSpace
=begin
module RbConfig
module Process
=end
DOC = <<~TEXT
  module RbConfig
  module MonitorMixin
TEXT
NOTE = "module ThreadGroup ; module Process"

p RbConfig::CONFIG.key?("host_os")
p ThreadGroup::Default.class

class Counter
  include MonitorMixin
  def initialize
    super()
    @n = 0
  end
  def bump = synchronize { @n += 1 }
end
c = Counter.new
c.bump
p c.bump

pid = Process.spawn("sh", "-c", "exit 3")
p Process.detach(pid).value.exitstatus

o = Object.new
ObjectSpace.define_finalizer(o, proc { })
p DOC.lines.size, NOTE.size
