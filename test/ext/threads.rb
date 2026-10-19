# An ext-init library whose entries start and join threads. The init used
# to end with the program-exit drain, which shut the scheduler down for good:
# the first entry's Thread found no worker to run it and its join waited
# forever. The toplevel starts the pool here, and leaves a thread behind
# whose message the second entry receives.
$log = Queue.new
Thread.new { 5 }.join
Thread.new { $log << :bg }
module ExtThreads
  #: (Integer) -> Integer
  def self.par(n)
    ts = []
    i = 0
    while i < n
      ts << Thread.new(i) { |k| k * 10 }
      i += 1
    end
    t = 0
    ts.each { |th| t += th.value }
    t
  end

  #: () -> Integer
  def self.bg
    $log.pop == :bg ? 1 : 0
  end
end
if __FILE__ == $0
  p ExtThreads.par(4)
  p ExtThreads.bg
end
