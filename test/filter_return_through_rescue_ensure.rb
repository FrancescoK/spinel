# A return out of a filter block or a synchronize body inside a rescue and an
# ensure pops the rescue's frame too on its way to the ensure: repeated, the
# exception stack ran out (#8275).
def first
  values = [1, 2]
  begin
    begin
      values.reject! { |v| return String.new("answer") if v == 1; false }
    rescue
    end
  ensure
    GC.start
  end
  "miss"
end
100.times { first }
p first

M = Mutex.new
def locked
  begin
    begin
      M.synchronize { return :locked }
    rescue
    end
  ensure
    :ignored
  end
  :miss
end
100.times { locked }
p locked
p M.locked?

def kept
  a = [1, 2, 3]
  begin
    begin
      a.select! { |v| return a if v == 2; true }
    rescue
    end
  ensure
    a << 9
  end
  :miss
end
100.times { kept }
p kept
