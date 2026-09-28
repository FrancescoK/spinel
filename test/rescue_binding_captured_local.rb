def kept
  pr = nil
  begin
    raise "boom"
  rescue => e
    pr = proc { e.message }
  end
  pr.call
end
p kept

def bound_in_proc
  e = nil
  pr = proc do
    begin
      raise ArgumentError, "in proc"
    rescue ArgumentError => e
    end
  end
  pr.call
  [e.class, e.message]
end
p bound_in_proc
