# A local bound to split's Array whose Strings an each block appends to, in
# a begin whose rescue retries: the retry runs the each again over the same
# Strings, so the first pass's appends must be seen by the second. Still
# refused, not silently applied to copies.
# spinel: reject-thread-string
out = []
a = "a;b".split(";")
i = 0
begin
  a.each { |x| x << "!"; out << x }
  i += 1
  raise "again" if i < 2
rescue
  retry
end
p out
