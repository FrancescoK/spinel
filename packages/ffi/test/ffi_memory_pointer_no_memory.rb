# A MemoryPointer whose buffer cannot be made raises NoMemoryError, as CRuby's
# ffi does. The backing store once answered an empty String with the full
# length, so the pointer took writes past its end, and a size past what a
# binary String carries (an int) wrapped to a short one. NoMemoryError is not
# a StandardError, so a bare rescue lets it through.
require "ffi"

[(1 << 46) + 5, 1 << 60].each do |n|
  begin
    FFI::MemoryPointer.new(:char, n)
    puts "allocated #{n}"
  rescue NoMemoryError => e
    puts "#{e.class}: #{e.message}"
  end
end

begin
  begin
    FFI::MemoryPointer.new(:char, 1 << 60)
  rescue => e
    puts "a bare rescue caught #{e.class}"
  end
rescue NoMemoryError
  puts "NoMemoryError passed a bare rescue"
end

# an ordinary pointer after the failures still works
mp = FFI::MemoryPointer.new(:char, 8)
mp.put_bytes(0, "abcdef")
p mp.get_bytes(0, 6), mp.size
