require_relative "required_lib"

class Top
  def run = Lib.go(5)
end

begin
  Top.new.run
rescue => e
  puts e.backtrace
end
