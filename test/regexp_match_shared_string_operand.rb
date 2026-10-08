# `/re/ =~ h[k]` where the Hash holds a String that was mutated after it was
# stored -- a shared-string handle inside the poly value, which is a String
# (webrick's HTTPResponse#setup_header matches its content-type header so)
h = {"n" => 1}
h["a"] = String.new("multipart/byteranges; boundary=x")
h["c"] = String.new("text/plain")
h["c"] << "; charset=utf-8"
p(%r{^multipart/byteranges} =~ h["a"])
p(%r{^multipart/byteranges} =~ h["c"])
p(/charset/ =~ h["c"])
p(/x/ =~ h["missing"])
begin
  /x/ =~ h["n"]
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
