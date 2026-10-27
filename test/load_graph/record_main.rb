# The load record's points (--dump-load-record, record_main.rb.load-record):
# BEGIN first, a required file at its load, class bodies and the blocks the
# load phase runs at once nested where they run, a branch and a program
# method's block as points that may not run, and no point in a method body
# or in a block kept to run later.
puts "main"
BEGIN { puts "begin" }
require_relative "record_lib"
class Shape
  attr_reader :w, :h
  %w[wide tall].each { |n| define_method(n) { n } }
  if ARGV.size > 5
    def odd = 1
  end
  KEEP = proc { puts "kept" }
  def area = w * h
end
def helper
  yield
end
helper { puts "maybe" }
puts Shape.new.area
puts Shape.new.tall
