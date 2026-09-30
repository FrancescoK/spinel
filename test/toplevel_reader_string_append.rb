# A mutation through a reader of a top-level ivar or a class-level ivar
# (both C globals) lands in the ivar's String, receiverless or through
# the class.
def tbuf; @tbuf ||= +""; end
tbuf << "x"
p tbuf
def g; tbuf << "y"; end
g
p tbuf
class K
  def self.buf; @buf ||= +""; end
  def self.go; buf << "x"; buf << "z"; p buf; end
end
K.go
p K.buf
K.buf << "w"
p K.buf
def arr; @arr ||= []; end
arr << 1
p arr
@log = +"a"
def log; @log; end
log << "b"
log.concat("c")
log.upcase!
p log
def buf; @buf ||= +""; end
def add(s) = buf << s
add("x"); add("y")
buf.prepend(">")
p buf
buf.replace("new")
p buf
buf.clear
p buf
module M
  def self.store; @store ||= +"m"; end
  def self.push(s); store << s; end
end
M.push("1")
M.store << "2"
p M.store
class C
  class << self
    def acc; @acc ||= +""; end
  end
  def self.run; acc << "r"; end
end
C.run
C.run
p C.acc
def plain; @plain ||= "x"; end
q = plain.dup
q << "y"
p plain, q
