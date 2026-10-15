# Hash#merge given an Exception, an IO or a MatchData raises CRuby's
# TypeError, named after the value's class. The argument's kind has no
# class name the compiler can spell (an exception is whichever subclass
# was raised), so it fell through to the receiver-layout merge helper and
# the C did not build (#9220).
def tag(args)
  { kind: "w" }.merge(args)
end

def try_tag(args)
  p tag(args)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

try_tag(StandardError.new("boom"))
try_tag(ArgumentError.new("bad"))

begin
  raise "from rescue"
rescue => e
  try_tag(e)
end

def merge_io(io)
  { "out" => 1 }.merge(io)
rescue TypeError => e
  "TypeError: #{e.message}"
end
puts merge_io($stdout)

def merge_match(m)
  { 1 => 2 }.merge(m)
rescue TypeError => e
  "TypeError: #{e.message}"
end
puts merge_match("abc".match(/b/))

p({ kind: "w" }.merge({ id: 1 }))
