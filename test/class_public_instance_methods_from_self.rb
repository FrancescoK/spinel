class Runnable
  def self.methods_matching(re) = public_instance_methods(true).grep(re).map(&:to_s)
  def self.runnable_methods = methods_matching(/^test_/).sort
end
class T1 < Runnable
  def test_a; end
  def test_b; end
  def helper; end
end
class T2 < T1
  def test_c; end
  private def test_hidden; end
end
p T1.runnable_methods
p T2.runnable_methods
[T1, T2].each { |k| p k.runnable_methods }
p T2.public_instance_methods(true).grep(/^test_/).sort
p T2.public_instance_methods(false).sort
