# A program that reopens String has a class of its own named String, which
# would be taken for the subclass's superclass: refused where the subclass
# is declared (#7449).
class String
  def yell = upcase + "!"
end

class Name < String
end

p Name.new("a").yell
