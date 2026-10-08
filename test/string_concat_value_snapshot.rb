# A concat used as a value takes every argument before appending any of
# them, including aliases held in boxes. The result keeps the receiver.
s = +"a"
other = s
other << "!"
# The first s snapshot spans the final s read's sp_strbuf_read_pub allocation.
result = s.concat(s, "b", s)
p s, result

s = +"x\0y"
other = s
other << "!"
arg = [s, 1][ARGV.size]
# The first arg copy spans sp_str_repeat and the final sp_str_concat copy.
# The repeated String spans that final sp_str_concat allocation too.
result = s.concat(arg, "z" * 100, arg)
p result.bytes, s == result


frozen = "frozen".freeze
begin
  value = frozen.concat("a", "b")
  p value
rescue FrozenError
  puts "frozen"
end
