# A block that finishes in time returns its value through Timeout.timeout
# and is passed sec; a nil or zero sec runs the block with no limit, and a
# negative one raises ArgumentError.
require "timeout"

class Job
  include Timeout

  def run
    timeout(1) { :job_done }
  end
end

Thread.new do
  p Timeout.timeout(1) { 42 }
  p Timeout.timeout(2) { |sec| sec * 2 }
  p Timeout.timeout(nil) { |sec| sec.inspect }
  p Timeout.timeout(0) { :zero }
  sum = 0
  200.times { |i| sum += Timeout.timeout(5) { i } }
  p sum
  begin
    Timeout.timeout(-1) { :never }
  rescue ArgumentError => e
    puts e.message
  end
  p Job.new.run
end.join
sleep 0.2
puts "no stray timeout"
