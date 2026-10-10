# A shared String handed on as the handle everywhere: the check marks its
# uses and finds no copy.
class Log
  def initialize
    @buf = +""
  end

  def add(s)
    @buf << s
    self
  end

  attr_reader :buf
end
log = Log.new
line = +"start"
log.add(line).add("!")
line << "?"
alias_of = line
alias_of << "."
puts log.buf, line, alias_of
puts line.equal?(alias_of)
