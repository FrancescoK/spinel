# A Data receiver and its member survive an allocating nil-valued argument.
D = Data.define(:a)
def make_data
  D.new(a: "a" * 12345)
end
def allocate_value
  GC.start
  1000.times { "x" * 1000 }
  nil
end
begin
  make_data.instance_variable_set(:@z, allocate_value)
rescue FrozenError => e
  p e.receiver.a.length
end
