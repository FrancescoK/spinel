# A call with keyword arguments alone and a block, on a receiver known only
# at run time, whose name a numeric builtin also answers with one positional
# (`div`): the dispatch's numeric default arm counted the keyword hash as
# that positional and read the temp of an argument that was never hoisted,
# and the C did not build (use of undeclared identifier '_t0').
class Xml
  def initialize = @out = []
  def out = @out
  def div(xmlns: nil, &blk)
    @out << "div #{xmlns}"
    blk.call(self) if blk
  end
  def entry(*args, &blk)
    @out << "entry #{args.inspect}"
    blk.call if blk
  end
  def text(s) = @out << "text #{s}"
end
class AtomBuilder
  def initialize(xml) = @xml = xml
  def xhtml_block?(method, arguments)
    arguments.last.is_a?(Hash) && arguments.last[:type] == "xhtml"
  end
  def method_missing(method, *arguments, &block)
    if xhtml_block?(method, arguments)
      @xml.__send__(method, *arguments) do
        @xml.div(xmlns: "http://www.w3.org/1999/xhtml") do |xhtml|
          block.call(xhtml)
        end
      end
    else
      @xml.__send__(method, *arguments, &block)
    end
  end
end
x = Xml.new
b = AtomBuilder.new(ARGV.empty? ? x : "str")
b.method_missing(:entry, 1, type: "xhtml") { |h| h.text("hi") }
b.method_missing(:text, "plain")
p x.out
