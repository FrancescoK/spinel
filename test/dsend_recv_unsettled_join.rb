# A send of a computed name whose receiver joins an Integer with a value
# whose type the inference has not reached when the send is lowered (the
# answer of a class method, read back out of an Array or a conditional):
# the arms are the program's methods as well as Integer's, so W#name is
# reached and an Integer still answers its own methods.
class W
  def name = @name
  def name=(v)
    @name = v
  end

  def self.from_row(row)
    w = W.new
    w.name = row[1]
    w
  end
end

w = W.from_row([+"7", +"a", 3])
nm = ("na" + "me").to_sym
o = [w, 1][0]
p o.public_send(nm)
q = (w.name.size > 0 ? w : 1)
p q.send(nm)
i = [w, 1][1]
p i.public_send(("su" + "cc").to_sym)
begin
  i.public_send(nm)
rescue NoMethodError => e
  p e.class
end
