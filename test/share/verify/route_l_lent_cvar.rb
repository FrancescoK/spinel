def grow(b) = (b << "x"; b.size)
def grow2(a, b) = (a << "1"; b << "2"; a.size + b.size)
class K; @@s = +"abc"; def self.go = (grow(@@s); @@s); end
p K.go
