require_relative 'cxl_sample'
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
