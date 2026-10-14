require_relative 'cxl_sample'
raise 'I/O unblock sentinel dispatch' unless CxlSample.io_unlocked == 2
thread = Thread.new do
  begin
    CxlSample.wait_interrupt
  ensure
    puts 'kill ensured'
  end
end
sleep(0.001) until CxlSample.waiting?
GC.start
thread.kill
thread.join
CxlSample.reset
thread = Thread.new do
  begin
    CxlSample.wait_interrupt
  rescue RuntimeError => error
    puts error.message
  ensure
    puts 'raise ensured'
  end
end
sleep(0.001) until CxlSample.waiting?
GC.start
thread.raise(RuntimeError, 'interrupted')
thread.join
puts CxlSample.serialized
CxlSample.reset
ensured = false
thread = Thread.new do
  begin
    CxlSample.wait_select
  ensure
    ensured = true
  end
end
sleep(0.001) until CxlSample.waiting?
GC.start
thread.kill
thread.join
raise 'select kill skipped ensure' unless ensured
CxlSample.reset
raised = false
thread = Thread.new do
  begin
    CxlSample.wait_select
  rescue RuntimeError => error
    raised = error.message == 'select interrupted'
  end
end
sleep(0.001) until CxlSample.waiting?
thread.raise(RuntimeError, 'select interrupted')
thread.join
raise 'select raise was lost' unless raised
CxlSample.reset
ensured = false
thread = Thread.new do
  begin
    CxlSample.wait_io
  ensure
    ensured = true
  end
end
sleep(0.001) until CxlSample.waiting?
thread.kill
thread.join
raise 'native I/O kill skipped ensure' unless ensured
CxlSample.reset
raised = false
thread = Thread.new do
  begin
    CxlSample.wait_io
  rescue RuntimeError => error
    raised = error.message == 'native I/O interrupted'
  end
end
sleep(0.001) until CxlSample.waiting?
thread.raise(RuntimeError, 'native I/O interrupted')
thread.join
raise 'native I/O raise was lost' unless raised
