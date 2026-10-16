# String#delete reached by dispatch takes a shared String argument (#9258)
class K
  def delete(src) = "k" + src
end
s = +"gif"
[K.new, "string"].each { |v| p v.delete(s) << "!" }
