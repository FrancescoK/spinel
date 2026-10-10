# A retry in a rescue clause is valid beside an ensure: one in the begin an
# ensure closes, and one in a rescue inside a block an ensure runs (#8377).
n = 0
begin
  n += 1
  raise "x" if n < 3
rescue
  begin
    retry if n < 3
  ensure
    n += 0
  end
end
p n
def m
  yield
ensure
  tries = 0
  [1].each do |x|
    begin
      tries += 1
      raise "y" if tries < 2
    rescue
      retry
    end
  end
  p tries
end
m { p :ok }
