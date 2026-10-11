# A block that runs past its time is interrupted: with no class given the
# caller sees Timeout::Error (which a `rescue StandardError` inside the
# block does not catch), else the given class and message.
require "timeout"

class SlowError < StandardError; end

class Job
  include Timeout

  def run
    timeout(0.05) { sleep 1; :late }
  rescue Timeout::Error => e
    "Job: #{e.message}"
  end
end

Thread.new do
  begin
    Timeout.timeout(0.05) { sleep 1; puts "not reached" }
  rescue Timeout::Error => e
    puts "#{e.class}: #{e.message}"
  end
  begin
    Timeout.timeout(0.05) do
      begin
        sleep 1
      rescue StandardError
        puts "not reached either"
      end
    end
  rescue Timeout::Error => e
    puts "outside the block: #{e.class}"
  end
  begin
    Timeout.timeout(0.05, SlowError, "too slow") { sleep 1 }
  rescue SlowError => e
    puts "#{e.class}: #{e.message}"
  end
  inner = Timeout.timeout(1) do
    begin
      Timeout.timeout(0.05) { sleep 1 }
    rescue Timeout::Error
      :inner_expired
    end
  end
  p inner
  p Job.new.run
end.join
