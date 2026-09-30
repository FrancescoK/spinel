# print and puts on an ivar that holds $stdout in one object and a StringIO
# in another reach the IO too, not only the StringIO.
require "stringio"
class Term
  def initialize(input:, output:)
    @input = input
    @output = output
  end
  def header(lines)
    lines.each { |line| @output.print "#{line}\r\n" }
    @output.print "a", 1, "\n"
    @output.puts "x", [1, [2, "y"]], nil
    @output.puts
    @output.flush
  end
end
Term.new(input: $stdin, output: $stdout).header(["a"])
s = StringIO.new(+"")
Term.new(input: StringIO.new("x"), output: s).header(["b"])
p s.string
