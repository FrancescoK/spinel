# A block that is inside one long runtime call when its time runs out
# either finishes or gets Timeout::Error, inside Timeout.timeout: the
# interrupt never fires later, after Timeout.timeout has returned.
require "timeout"

big = Array.new(3_000_000) { |i| (i * 7919) % 1_000_003 }
Thread.new do
  3.times do
    outcome =
      begin
        Timeout.timeout(0.01) { big.sort.size }
        :finished_or_timed_out
      rescue Timeout::Error
        :finished_or_timed_out
      end
    begin
      sleep 0.05
      p outcome
    rescue Exception => e
      puts "stray #{e.class} after Timeout.timeout returned"
    end
  end
end.join
