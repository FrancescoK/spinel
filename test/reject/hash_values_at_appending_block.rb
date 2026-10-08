# A String a Hash holds, reached through values_at or fetch_values by an
# appending block, is not yet shared by reference: refused, not copied.
# spinel: reject-share
w = {a: +"w", b: +"v"}
w.values_at(:a).each { |v| v << "@" }
w.fetch_values(:b).each { |v| v << "!" }
p w
