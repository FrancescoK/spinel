# A global or class variable reaches only the method the call selects.
# Another method with the same name has a separate parameter and alias set.
def grow(v) = v << "g"
def keyed(v:) = v << "k"

class OtherTarget
  def self.grow(v) = v << "o"
  def self.keyed(v:) = v << "t"
  def self.run
    @@s = +"c"
    grow(@@s)
    keyed(v: @@s)
    p @@s
  end
end

$first = +"a"
grow($first)
keyed(v: $first)
p $first
OtherTarget.run
$second = +"b"
OtherTarget.grow($second)
OtherTarget.keyed(v: $second)
p $second
