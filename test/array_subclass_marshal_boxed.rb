# spinel: not-cruby -- Spinel refuses to dump an Array subclass instance; CRuby dumps it with its class and ivars.
# An Array subclass instance that reaches Marshal.dump through a value of any
# class (here an element of a mixed Array, or nested in an Array) raises
# TypeError: written as its Array, it would load back as a plain Array
# without its class and ivars. A plain Array still round-trips.
class Page < Array
  attr_accessor :n
end
pg = Page[1, 2]
pg.n = 3
x = [pg, "s"][ARGV.size]
[-> { Marshal.dump(x) }, -> { Marshal.dump([x, 1]) }].each do |f|
  f.call
  puts "dumped"
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
p Marshal.load(Marshal.dump([[1, 2], "s"][ARGV.size]))
