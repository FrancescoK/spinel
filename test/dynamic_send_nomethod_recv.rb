# A send by a Symbol variable naming a method the receiver lacks raises the
# NoMethodError CRuby words, naming the receiver; it said only
# "undefined method 'zork'".
x = [true, 1][0]
%i[with].each { |m| p((x.public_send(m) rescue $!.message)) }
%i[zork].each { |m| p((5.send(m) rescue $!.message)) }
%i[zork].each { |m| p(("s".public_send(m) rescue $!.message)) }
%i[zork].each { |m| p(([1].send(m) rescue $!.message)) }
class A
  def hi = 1
end
%i[hi zork].each { |m| p((A.new.send(m) rescue $!.message)) }
%i[upcase].each { |m| p "ab".send(m) }
def side = (print "S"; 5)
%i[zork].each { |m| p((side.send(m) rescue $!.message)) }
