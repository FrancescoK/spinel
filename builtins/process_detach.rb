# Process.detach, spliced by the parser when a program (or a library it
# requires) names it: a thread that reaps the child and whose value is its
# Process::Status, as CRuby's Process::Waiter is (#7203). The thread waits
# through the scheduler, so it does not hold up the program's other threads.
module Process
  def self.detach(pid)
    Thread.new { Process.waitpid2(pid)[1] }
  end
end
