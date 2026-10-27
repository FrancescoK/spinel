# An unresolved qualified constant (`Mylib::VERSION`, Mylib undefined) degrades
# to a rescuable runtime NameError rather than emitting a bare `Mylib_VERSION` C
# identifier (undeclared -> C compile error). The constant would once have come
# from `require "mylib/version"`, but under SPINEL_STRICT_REQUIRE an unsatisfiable
# require is itself a compile error, so the realistic program just references the
# constant; the rescuable-NameError behaviour is what matters here.
begin
  puts Mylib::VERSION
rescue NameError => e
  puts "rescued: #{e.message}"
end
puts "after"
