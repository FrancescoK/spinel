# spinel: reject-send-super
# `super` from a program-defined send that does more than call super reaches
# Object#send, which dispatches on the name at run time. CRuby prints
# "send size" and 3; Spinel has no Object#send to put behind a program
# method's super, and used to raise "super: no superclass method 'send'" at
# run time. It is refused at this line instead.
class Logged
  def send(name, *args)
    puts "send #{name}"
    super
  end
  def size = 3
end
p Logged.new.send(:size)
