# A --debug backtrace frame inside a block reads `block in X`, or
# `block (N levels) in X`, as CRuby's does (backtrace-test).
require_relative "block_frames_lib"

def show
  yield
rescue => e
  puts e.backtrace.first
end

class Runner
  def run
    show do
      raise "in a do block"
    end
    show { [1].each { |x| raise "two levels on one line" } }
    show do
      [1].each do |x|
        [2].each do |y|
          raise "three levels"
        end
      end
    end
  end
end

Runner.new.run
show do
  raise "at the top level"
end
show { raise "on one line" }
show { lib_blocks }
