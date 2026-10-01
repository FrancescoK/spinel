# warn(..., uplevel: 0) prefixes the first line with the location of the
# warn call itself -- "file:line: warning: " -- which is known where it is
# written; the messages follow as a plain warn prints them. The pure-Ruby
# DateTime warns this way about an offset it ignores.
def offset_of(of)
  return of if of.is_a?(Integer)
  warn("invalid offset is ignored: #{of}", uplevel: 0)
  0
end

p offset_of(3600), offset_of("bogus")
warn("first", "second", uplevel: 0)
warn(["x", "y"], uplevel: 0)
warn("ends in newline\n", uplevel: 0)
warn(uplevel: 0)
puts "done"
