class T
  attr_writer :a

  def initialize(a = 1)
    @a = a
  end

  def x = @a

  def show(names)
    names.map { |at| "#{at}=#{send(at).inspect}" } * ' '
  end
end
t = T.new
t.a = 2
puts t.show(%w[x])
p T.private_method_defined?(:initialize)
