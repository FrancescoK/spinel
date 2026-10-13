# `self.x = v` in a class method calls the writer of the class self is, as
# `x` and `self.x` there call its reader. The reader form already dropped
# `self` and took the class-method dispatch; the writer kept it, and no arm
# took a setter on a self that is a class, so the call was refused as
# unsupported.
class Base
  def self.table_name=(value)
    puts "#{name}.table_name= #{value}"
    @table_name = value
  end

  def self.table_name
    @table_name
  end

  def self.reset_table_name
    self.table_name = "#{name.downcase}s"
  end

  def self.count=(n)
    @count = n
  end

  def self.count
    @count
  end

  def self.bump
    self.count = (count || 0) + 1
  end
end

class User < Base; end

class Post < Base
  def self.table_name=(value)
    puts "Post's own writer"
    @table_name = "posts_table"
  end
end

Base.reset_table_name
User.reset_table_name
Post.reset_table_name
p Base.table_name, User.table_name, Post.table_name
User.bump
User.bump
p User.count, Base.count
