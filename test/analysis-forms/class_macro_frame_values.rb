# A class-body macro run where the body calls it: each define_method it
# runs is written in the call's place, its block reading what the macro's
# frame holds when the macro returns.
class Model
  def self.field(name, default, flag)
    getter = "#{name}_value"
    define_method(getter) { |x = default, *rest, k: flag, &blk| [x, rest, k, blk ? blk.call : nil] }
    define_method("#{name}_info") do
      "#{self.class.name}: #{name} #{default.inspect} #{flag}"
    end
  end

  def self.counter(name, start)
    define_method(name) do
      [1, 2].map { |i| i + start }.sum
    end
  end

  def self.choose(name, big)
    if big
      define_method(name) { :big }
    else
      define_method(name) { :small }
    end
  end

  def self.label(name, text)
    define_method(name) { text }
  end
end

class Post < Model
  field :title, 3, true
  field :body, nil, :yes
  counter :total, 10
  choose :size, false
  label :who, "writer"
end

post = Post.new
p post.title_value
p post.title_value(5, 6, k: 7) { 8 }
p post.body_value
puts post.title_info, post.body_info
p post.total, post.size, post.who, post.who.equal?("writer")
p Post.public_method_defined?(:title_value), Post.instance_method(:title_value).parameters
