# Only a literal self receiver may call a private method.
class VisibilityReceiver
  def literal
    p self.secret
    self.secret = 2
    p self.secret
    self.secret += 3
    p self.secret
    self.secret ||= 9
    self.secret &&= 7
    p self.secret
    p self&.secret
    self.secret, other = 8, 0
    p self.secret
    p other
    for self.secret in [10, 11]
    end
    p self.secret
  end

  def parenthesized
    begin
      (self).secret
    rescue NoMethodError
      puts "paren read"
    end
    begin
      ((self)).secret
    rescue NoMethodError
      puts "nested read"
    end
    begin
      (self).secret = 99
    rescue NoMethodError
      puts "paren write"
    end
    begin
      (self).secret += 99
    rescue NoMethodError
      puts "paren op write"
    end
    begin
      (self).secret ||= 99
    rescue NoMethodError
      puts "paren or write"
    end
    begin
      (self).secret &&= 99
    rescue NoMethodError
      puts "paren and write"
    end
    begin
      for (self).secret in [99]
      end
    rescue NoMethodError
      puts "paren for target"
    end
    begin
      self.public_send(:secret)
    rescue NoMethodError
      puts "public send refused"
    end
    p self.send(:secret)
    other = self
    begin
      other.secret
    rescue NoMethodError
      puts "local read"
    end
  end

  private
  def secret
    @secret || 1
  end
  def secret=(value)
    @secret = value
    42
  end
end
obj = VisibilityReceiver.new
obj.literal
obj.parenthesized

# Reopening a user class keeps the same permission.
class VisibilityReceiver
  def reopened_probe
    p self.secret
    begin
      (self).secret
    rescue NoMethodError
      puts "reopen paren"
    end
  end
end
obj.reopened_probe

# A class body's call keeps its permission when given a class constant.
class ClassVisibilityReceiver
  def self.hidden
    12
  end
  private_class_method :hidden
  p self.hidden
  begin
    (self).hidden
  rescue NoMethodError
    puts "class paren"
  end
end

class IndexVisibilityReceiver
  def run
    p self[0]
    self[0] = 2
    self[0] += 3
    p self[0]
    self[0] ||= 7
    self[0] &&= 9
    p self[0]
    begin
      (self)[0] += 1
    rescue NoMethodError
      puts "index paren"
    end
  end
  private
  def [](key)
    @value || 1
  end
  def []=(key, value)
    @value = value
  end
end
IndexVisibilityReceiver.new.run

# Reflective calls keep their own visibility policy when lowered on main.
def visibility_receiver_helper; 14; end
p (self).send(:visibility_receiver_helper)
names = [:visibility_receiver_helper]
p (self).send(names[0])
begin
  (self).public_send(:visibility_receiver_helper)
rescue NoMethodError
  puts "main public send refused"
end
