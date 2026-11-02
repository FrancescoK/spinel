class Helper
  def add(k) = (puts "adding to #{k}"; :done)
end
class K; end
o = Helper.new
p K.class_eval(&o.method(:add))
