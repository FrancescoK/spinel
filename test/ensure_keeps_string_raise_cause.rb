# A String raise's cause, explicit or the exception being handled, survives
# an ensure, a filter block and a synchronize body that raise it again on
# their way out (#8272).
# spinel: gc-stress
seed = RuntimeError.new("seed")

def show(label)
  yield
rescue => e
  p [label, e.message, e.cause&.message]
end

x = 0
show(:ensure) do
  begin
    raise "boom", cause: seed
  ensure
    x += 1
  end
end
show(:filter) do
  begin
    [1].reject! { |v| raise "boom", cause: seed if v == 1; false }
  ensure
  end
end
show(:filter_bare) { [1].select! { |v| raise "boom", cause: seed if v == 1; true } }
show(:synchronize) { Mutex.new.synchronize { raise "boom", cause: seed } }
show(:implicit) do
  begin
    raise "outer"
  rescue
    begin
      raise "inner"
    ensure
      x += 1
    end
  end
end
show(:none) do
  begin
    raise "plain"
  ensure
    x += 1
  end
end
show(:nested) do
  begin
    begin
      raise "deep", cause: seed
    ensure
      x += 1
    end
  ensure
    x += 1
  end
end
p x
