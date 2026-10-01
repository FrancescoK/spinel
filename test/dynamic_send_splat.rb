# `recv.public_send(*args, &blk)` and its receiverless form: the method name
# is the first element of a splatted array, the rest are its arguments, and
# the block is forwarded -- activesupport's Object#try. The explicit form
# interned the whole array as the name ("undefined method '[:name]'"); the
# receiverless public_send was refused outright.
class Person
  def initialize(n) = @n = n
  def name = @n
  def greet(g, punct = "!") = "#{g}, #{@n}#{punct}"
  def each_letter = @n.each_char { |ch| yield ch }
  def try(*args, &block)
    if args.empty? && block_given?
      yield self
    elsif respond_to?(args.first)
      public_send(*args, &block)
    end
  end
  def relay(*args) = public_send(*args)
end
pe = Person.new("Ann")
p pe.try(:name)
p pe.try(:greet, "Hi")
p pe.try(:greet, "Yo", "?")
p pe.try(:nope)
pe.try(:each_letter) { |ch| print ch, "." }
puts
p pe.try { |x| x.name.upcase }
def call_it(obj, *args) = obj.public_send(*args)
p call_it(pe, :name)
p call_it(pe, :greet, "Hey")
r = [:greet, "Yo", "?"]
p pe.public_send(*r)
p pe.send(*r)
p pe.relay(:greet, "Ho")
begin
  pe.relay(:nope)
rescue NoMethodError => e
  puts "NoMethodError: #{e.message[0, 23]}"
end
