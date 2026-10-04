# A Hash#merge argument that is a name nothing defines raises NameError
# before the merge, whatever the receiver's layout (#7276, #7277).
class C
  def f(x)
    { a: x }.merge(local_assigns.slice(:b, :c))
  end

  def g
    Hash.new(0).merge(totals.transform_values { |x| x.to_i })
  end

  def h
    { "k" => 1 }.merge(extra)
  end
end

[:f, :g, :h].each do |m|
  begin
    m == :f ? C.new.f(1) : C.new.send(m)
  rescue NameError => e
    puts e.message
  end
end
