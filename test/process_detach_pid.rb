# The thread Process.detach answers is CRuby's Process::Waiter: its #pid is
# the child's pid, also read through a global that may still be nil
# (`$t&.pid`). Spinel's waiter was a plain Thread, so #pid was an unsupported
# call. Another thread has no #pid.
def waiter_pid = $t&.pid
p waiter_pid

pid = Process.spawn("sh", "-c", "exit 4")
$t = Process.detach(pid)
p waiter_pid == pid, $t.pid == pid
p $t.value.exitstatus, $t.pid == pid

begin
  Thread.new {}.pid
rescue NoMethodError => e
  p e.message
end
