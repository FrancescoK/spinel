# a regexp operator whose receiver is a bare name that resolves to nothing
# raises NameError at run time instead of breaking the C build
module M
  def m? = dir.match?(/x/)
end
class T
  def m? = true
end
p T.new.m?

class U
  def a = dir.match?(/x/)
  def b = dir =~ /x/
  def c = dir !~ /x/
  def d = dir.match(/x/)
end
%i[a b c d].each do |s|
  begin
    p U.new.send(s)
  rescue NameError => e
    puts e.message
  end
end
