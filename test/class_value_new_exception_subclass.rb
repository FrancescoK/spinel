# A Class value holding a user exception class constructs it with new, and
# `new` on a class or module that has none names the receiver as CRuby does.

class AppError < StandardError; end
class DefaultError < StandardError
  def initialize(msg = "default message"); super; end
end
class CodedError < RuntimeError
  attr_accessor :code
end
module Outer
  class Inner < ArgumentError; end
end
class Plain; end

def described(e)
  raise e
rescue => x
  "#{x.class}: #{x.message}"
end

puts described([AppError, 1][0].new("boom"))
puts described([AppError][0].new)
puts described([AppError][0].new(nil))
puts described([AppError][0].new(42))
puts described([CodedError][0].new("coded"))
puts described([DefaultError][0].new("given"))
puts described([DefaultError][0].new)
puts described([Outer::Inner][0].new("nested"))
begin
  [AppError][0].new(1, 2)
rescue ArgumentError => e
  puts e.message
end

k = ARGV.size > 5 ? Plain : AppError
puts described(k.new("typed"))
k = ARGV.size > 5 ? Plain : DefaultError
puts described(k.new)

begin
  raise [Outer::Inner][0].new("rescued")
rescue ArgumentError => e
  puts "#{e.class} #{e.message}"
end

module Mixin; end
[[Integer][0], [Mixin][0], [Comparable][0]].each do |c|
  begin
    c.new
  rescue NoMethodError => e
    puts e.message
  end
end
begin
  [Integer][0].bogus
rescue NoMethodError => e
  puts e.message
end
