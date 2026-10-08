# A loop's result slot keeps a constant's handle even when typed STRBUF.
module LoopStrings
  TEXT = "frozen"
  MUTABLE = +"mutable"
end
value = loop do
  begin
    break LoopStrings::TEXT
  ensure
    p "ensure#{ARGV.size}"
  end
end
p [LoopStrings::TEXT.equal?(value), value.frozen?]
begin
  value << "!"
rescue FrozenError
  puts "frozen"
end
p [LoopStrings::TEXT, value]
value = loop { break LoopStrings::MUTABLE }
value << "!"
p [LoopStrings::MUTABLE, value, LoopStrings::MUTABLE.equal?(value)]
