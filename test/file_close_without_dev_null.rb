# Closing a handle swaps its FILE for a shared sentinel opened on /dev/null.
# A WASI host has no /dev/null, so there the sentinel is an empty in-memory
# stream: close must not raise, and the closed handle still reads as closed.
# spinel: wasm
f = File.open(__FILE__)
puts f.gets.start_with?("# Closing")
f.close
puts f.closed?
begin
  f.gets
rescue IOError => e
  puts "IOError: #{e.message}"
end
g = File.open(__FILE__)
g.close
puts g.closed?
