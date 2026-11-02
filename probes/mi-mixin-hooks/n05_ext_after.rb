# extended: hook defined after the first extend
module M; end
class A
  extend M
end
module M
  def self.extended(b) = puts("ext #{b}")
end
class B
  extend M
end
puts "done"
