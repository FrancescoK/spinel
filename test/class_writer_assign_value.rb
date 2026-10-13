# `Klass.x = v` is an assignment: its value is v as written, whatever the
# class's writer `def self.x=(v)` returns, as it is for an instance's writer.
# The class-method call answered the writer's body instead.
class Config
  def self.mode=(value)
    @mode = value.to_s
    :ignored
  end

  def self.mode
    @mode
  end

  def self.limit=(n)
    @limit = n * 2
  end

  def self.limit
    @limit
  end
end

class Sub < Config; end

a = (Config.mode = 5)
p a, Config.mode
b = (Sub.mode = :fast)
p b, Sub.mode
c = (Config.limit = 3)
p c, Config.limit
p(Sub.limit = 4)
p [Config.mode = "x", Sub.mode = "y"]
