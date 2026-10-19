# A String handle passed to a boxed parameter of a call whose receiver may
# be nil: the argument runs ahead of the receiver's nil test, and was held
# as its value form, a copy of its bytes, which the arm then boxed as the
# handle (sp_box_nullable_obj of a const char *): the method read the
# first bytes of the key as a data pointer (#9602). The argument is held as
# the handle now.
class Answer
  def signed_with?(key)
    key.bytesize
  end
end

class Phone
  attr_reader :key

  def initialize
    @key = "".b
  end

  def learn(realm)
    @key = "kondae:#{realm}:achasan".b
    @key << "!"
  end
end

def take(codes)
  codes.shift ? Answer.new : nil
end

q = Queue.new
q << "Jayang".b
phone = Phone.new
phone.learn("gwangjin")
p Answer.new.signed_with?(q.pop)
m = take([200])
p m.signed_with?(phone.key)
p phone.key
