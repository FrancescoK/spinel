# A split's each in the rescue clause of a begin that retries: the retry
# re-enters the body, which raises into the rescue again, so the each runs
# twice over the same Strings. Still refused, not silently applied to copies.
# spinel: reject-thread-string
out = []
a = "a;b".split(";")
i = 0
begin
  raise "again" if i < 2
rescue
  a.each { |x| x << "!"; out << x }
  i += 1
  retry
end
p out
