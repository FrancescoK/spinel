# A thread, queue or mutex named only in a method nothing calls is no thread
# of the program: it runs on the one main thread, and SIGINT and SIGTERM with
# no trap still raise Interrupt and SignalException there, as CRuby's default
# does, so rescue and ensure run (#7202). The methods below are never called:
# one names a Thread, one a Queue and a Mutex, one is reached only from the
# first, one names it inside a block, and one is a class's. Reopening
# Thread to add a method that nothing calls starts none either.
$stdout.sync = true

def spawn_worker
  Thread.new { 1 + 1 }
end

def make_lock
  [Queue.new, Mutex.new]
end

def start_all
  spawn_worker.join
  make_lock
end

def spawn_in_block
  [1, 2].each { |i| Thread.new { i }.join }
end

class Pool
  def run
    Thread.new { :pool }.value
  end

  def self.shared
    Mutex.new
  end
end

class Thread
  def tag = :tagged
end

def used = 21 * 2

puts used
begin
  Process.kill("INT", Process.pid)
  sleep 1
  puts "not interrupted"
rescue Interrupt => e
  puts "rescued #{e.class} (#{Signal.signame(e.signo)})"
end
begin
  begin
    Process.kill("TERM", Process.pid)
    sleep 1
  ensure
    puts "ensure ran"
  end
rescue SignalException => e
  p [e.class, e.message, e.signo]
end
puts "done"
