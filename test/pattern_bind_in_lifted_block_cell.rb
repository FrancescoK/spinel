# A case/in binding inside an each_with_index block that is lifted to a
# proc (the receiver is an Array at one call and a Hash at the other)
# writes the local through its cell; it wrote the plain local nothing
# declared (#10014).
Box = Struct.new(:v)

def show(xs)
  xs.each_with_index do |a, i|
    case a
    in Box[v:] then puts v
    else puts i
    end
  end
end

show([Box.new("x")])
show({ k: 1 })
