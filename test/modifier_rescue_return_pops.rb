# A return or retry out of a modifier rescue leaves the exception it holds and
# the frame its guard opened: looped, either one ran out of rescue nesting or
# of stack (#8273, #8274).
def answer
  i = 0
  while i < 2
    i += 1
    raise "caught" rescue (return String.new("answer") if i > 0)
  end
  String.new("done")
end
100.times { answer }
p answer

def value(i)
  x = (raise "a" rescue (return String.new("r#{i}") if i > 0; "v"))
  x
end
200.times { |i| value(i) }
p value(0), value(1)

n = 0
begin
  raise "outer"
rescue
  n += 1
  (retry if n < 100) rescue nil
end
p n
p $!
