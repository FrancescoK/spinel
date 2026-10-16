# Process.detach, spliced by the parser when a program (or a library it
# requires) names it: a thread that reaps the child and whose value is its
# Process::Status, as CRuby's Process::Waiter is (#7203). The thread waits
# through the scheduler, so it does not hold up the program's other threads.
# The waiter keeps the child's pid, which its #pid answers; any other thread
# has no #pid, as in CRuby. (The NoMethodError is raised outside Thread,
# where a bare raise would be Thread#raise.)
module Process
  def self.detach(pid)
    waiter = Thread.new { Process.waitpid2(pid)[1] }
    waiter[:__process_waiter_pid] = pid
    waiter
  end

  def self.__no_waiter_pid
    raise NoMethodError, "undefined method 'pid' for an instance of Thread"
  end
end

class Thread
  def pid
    self[:__process_waiter_pid] || Process.__no_waiter_pid
  end
end
