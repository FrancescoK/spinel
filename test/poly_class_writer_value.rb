# Assignment answers the RHS, not the writer's return, in both class and
# instance arms of a boxed receiver's dispatch (#6557). An explicit method
# call still answers the writer's return.
class Current
  def self.instance
    value = Thread.current[:current]
    return value if value.is_a?(Current)
    value = Current.new
    Thread.current[:current] = value
    value
  end

  def user
    @user
  end

  def user=(value)
    @user = value
    101
  end

  def self.user=(value)
    Current.instance.user = value
    103
  end
end

Current.user = 47
p Current.instance.user

def assign(target, value)
  target.user = value
end

def invoke(target, value)
  target.public_send(:user=, value)
end

p assign(Current, 59)
p Current.instance.user
p assign(Current.instance, 83)
p Current.instance.user
p invoke(Current, 89)
p Current.instance.user
p invoke(Current.instance, 97)
p Current.instance.user
