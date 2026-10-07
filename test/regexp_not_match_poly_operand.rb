# `/re/ !~ x` where x is a String at one call and nil at another (webrick's
# Logger#log appends a newline `if /\n\Z/ !~ data`): the negated match on a
# string, true for nil, and the TypeError =~ raises for anything else.
def log(data)
  data += "\n" if /\n\Z/ !~ data
  data
end
p log("a")
p log("b\n")

def nm(v) = /\A\d+\z/ !~ v
p nm("80"), nm("x"), nm(nil)
begin
  nm(8080)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
p(/x/ !~ nil)

# a String that is mutated after it is stored is held in the Hash as a
# shared-string handle
h = {"a" => 1}
h["s"] = String.new("text/plain")
h["s"] << "; charset=utf-8"
p(/charset/ !~ h["s"], /multipart/ !~ h["s"])
