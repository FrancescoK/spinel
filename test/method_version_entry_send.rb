# A call that can reach two versions of a method, in a method only a
# send of a name held in a variable calls, answers the version defined
# when it runs.
class K
  def v = 1
  def self.w = 10
end

class C
  def via = K.new.v
  def cvia = K.w
end

def run(name) = C.new.public_send(name)
def run2(name) = C.new.send(name)
p run(:via), run2(:cvia)

class K
  def v = 2
  def self.w = 20
end

p run(:via), run2(:cvia)
