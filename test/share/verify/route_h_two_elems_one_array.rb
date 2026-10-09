a = [+"a"]
a << a[0]
a.each { |x| x << "!" if x.equal?(a[1]) }
p a
