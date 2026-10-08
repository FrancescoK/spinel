# A multi-argument concat hands its receiver's handle to the next holder.
s = +"a"
other = s
other << "!"
result = s.concat(s, "b", s)
result << "?"
p s, other, result, result.equal?(s)
