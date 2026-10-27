# Whether the program names a method by a String (--dump-load-record,
# record_strings_main.rb.load-record): a version of Box#get may run outside
# its interval, since a String spells its name, and one of Box#put may not.
# The scan read a field a StringNode does not have (its text is `content`)
# and the dump of a program with a String and a method of two versions
# crashed.
class Box
  def get = 1
  def get = 2
  def put = 3
  def put = 4
end
box = Box.new
p box.get, box.put
puts "get"
