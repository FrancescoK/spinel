# print and puts on an IO reached through a class-id dispatch: the receiver
# can also hold a StringIO, or a user class defines a method of the name.
# The dispatch had no IO arm for either and raised NoMethodError (#6158).
require "stringio"

class Term
  def initialize(output) = @output = output
  def header(lines)
    lines.each { |line| @output.print "#{line}\n" }
    @output.puts "--"
    @output.puts [1, [2, nil]], :sym
    @output.print "3", " ", "4.5\n"
    @output.puts
    r = @output.puts("x")
    @output.puts r.inspect
  end
end
Term.new($stdout).header(["a", "b"])
s = StringIO.new(+"")
Term.new(s).header(["c"])
p s.string

class Sink
  def print(*args) = @got = args
  def puts(*args) = @got = args
  def got = @got
end
outs = [$stdout, Sink.new]
outs.each do |o|
  o.print "via #{o.class}\n"
  o.puts "and puts"
  o.print 7, :k, nil, 1.5, "\n"
  o.puts [3, [4]], nil
end
p outs[1].got
