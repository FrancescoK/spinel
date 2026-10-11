# map! over split's Array whose block appends to each String, in a begin
# whose rescue retries: the second pass mutates the Strings the first one
# handed to `out`. Still refused, not silently applied to copies.
# spinel: reject-thread-string
out = []
a = "a;b".split(";")
i = 0
begin
  a.map! { |x| x << "!"; out << x; x }
  i += 1
  raise "again" if i < 2
rescue
  retry
end
p out
