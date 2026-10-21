# Object methods on builtin receiver families retain their resolved target.
class Object
  def tag = "object"
  def pick
    block_given? ? yield(7) : 8
  end
end
p /a/.tag, /a/.match("a").tag, true.tag, false.tag
p [1].tag, { a: 1 }.tag, (1..2).tag, Time.at(0).tag
p /a/.match("a").pick { |n| n + 1 }
p false.pick
