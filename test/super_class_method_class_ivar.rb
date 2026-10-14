# `super` from a class method runs the parent's method with self still the
# calling class, so a class-level @ivar it names is the calling class's
# own. An inherited class method is specialized per class for that, but a
# class that defines the name itself was never given a copy of the
# parent's: its super ran the parent's own body, which wrote the parent's
# slot.
class Base
  def self.table_name=(value)
    @table_name = value.to_s
  end

  def self.table_name
    @table_name
  end

  def self.register(n)
    @count = (@count || 0) + n
  end

  def self.count = @count
end

class Post < Base
  def self.table_name=(value)
    super("posts_#{value}")
  end

  def self.register(n)
    super(n * 10)
  end
end

class User < Base; end

Base.table_name = "base"
Post.table_name = "x"
User.table_name = "users"
p Base.table_name, Post.table_name, User.table_name
Base.register(1)
Post.register(2)
Post.register(3)
p Base.count, Post.count, User.count
