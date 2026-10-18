# start_with? with a Regexp that is not written inline: one built at run
# time, one read out of a container, and a receiver known only at run time.
HEAD = Regexp.new("#\\s*todo")

def text(x) = x

boxed = text(ARGV.size > 3 ? :sym : "# todo: one")
p boxed.start_with?(HEAD)
p boxed.start_with?(/#/)
p boxed.start_with?("x", HEAD)

plain = "#   todo two"
p plain.start_with?(HEAD)
p "todo #".start_with?(HEAD)

pats = [HEAD, "#  "]
p plain.start_with?(pats[0])
p plain.start_with?(pats[1])
p plain.start_with?(pats[ARGV.size + 1], pats[0])
p "-".start_with?(pats[0], pats[1])

sym = text(ARGV.size > 3 ? "s" : :"# todo")
p sym.start_with?(HEAD)

begin
  plain.start_with?([1, 2][ARGV.size])
rescue TypeError => e
  p e.message
end
