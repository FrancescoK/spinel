require_relative "required_lib"

class Top
  def run = Lib.go(5)
end

begin
  Top.new.run
rescue => e
  puts e.backtrace
end

def entry_run = lib_outer(7)

begin
  entry_run
rescue => e
  puts e.backtrace
end
