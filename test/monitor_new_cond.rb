require "monitor"

monitor = Monitor.new
condition = monitor.new_cond
p monitor.mon_owned?
p condition.class.name
p monitor.synchronize { monitor.mon_owned? }
p monitor.mon_owned?

ready = Queue.new
finished = false
waiter = Thread.new do
  monitor.synchronize do
    monitor.synchronize do
      ready << true
      condition.wait_until { finished }
      p monitor.mon_owned?
    end
    p monitor.mon_owned?
  end
end
ready.pop
monitor.synchronize do
  finished = true
  p condition.signal.class.name
end
waiter.join
p monitor.mon_owned?

timed = Thread.new do
  monitor.synchronize do
    ready << true
    condition.wait(5)
  end
end
ready.pop
monitor.synchronize { condition.signal }
p timed.value

monitor.synchronize do
  p condition.wait(0)
  p condition.wait(0.001)
  p condition.broadcast.class.name
end

begin
  condition.signal
rescue ThreadError => e
  puts e.message
end
begin
  condition.broadcast
rescue ThreadError => e
  puts e.message
end
begin
  condition.wait(0)
rescue ThreadError => e
  puts e.message
end

begin
  Mutex.new.new_cond
rescue NoMethodError
  puts "Mutex has no new_cond"
end
begin
  Mutex.new.mon_owned?
rescue NoMethodError
  puts "Mutex has no mon_owned?"
end

class OwnCondition
  def new_cond = :own
  def mon_owned? = :owned
end
p OwnCondition.new.new_cond
p OwnCondition.new.mon_owned?
p [monitor, OwnCondition.new].map(&:mon_owned?)

class Driver
  def initialize
    @mutex = Monitor.new
    @condition = @mutex.new_cond
  end

  def ready?
    @mutex.synchronize { @condition.wait(0) }
  end

  def owned? = @mutex.mon_owned?
end

driver = Driver.new
p driver.owned?
p driver.ready?
