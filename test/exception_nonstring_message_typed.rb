# A #message override that answers something other than a String, called on
# a receiver whose class is known: the override's own value comes back, as
# it does through $! in exception_nonstring_message.rb.

class TM < StandardError
  def message = :mm
end
p TM.new.message
e = TM.new
p e.message

class TI < StandardError
  def message = 42
end
x = TI.new.message
p x + 1

# nil or a String, the shape of a message kept beside a response
class TN < StandardError
  def initialize(msg) = @msg = msg
  def message = @msg || "from the response"
end
puts TN.new(nil).message
begin
  raise TN.new(nil)
rescue TN => err
  puts "rescued: #{err.message}"
end

# #message wins over #to_s when the class has both
class TB < StandardError
  def message = "the message"
  def to_s = :the_to_s
end
p TB.new.message
p TB.new.to_s

# an inherited override answers for the subclass
class TF < TM; end
p TF.new.message
